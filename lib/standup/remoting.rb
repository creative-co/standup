require 'tempfile'

module Standup
  class Remoting
    def initialize node
      @node = node
      @host = @node.instance.external_ip
      @keypair_file = Settings.aws.keypair_file
      @user = @node.scripts.ec2.params.ssh_user
      @ssh = nil
      @context = {}
    end
    
    def download *files
      options = files.pop
      rsync wrap_to_remote(files), options[:to], options[:sudo]
    end
    
    def upload *files
      options = files.pop
      rsync files, wrap_to_remote(options[:to]), options[:sudo]
    end
    
    def remote_update file, body, opts = {}
      tmpfile = Tempfile.new('file')

      success = download file,
                         :to => tmpfile.path,
                         :sudo => opts[:sudo]
      unless success 
        bright_p 'error during file upload'
        return
      end
  
      opts[:delimiter] ||= '# standup remote_update fragment'
      
      initial = File.read(tmpfile.path)
      
      to_change = "#{opts[:delimiter]}\n#{body}#{opts[:delimiter]}\n"
      pattern = /#{opts[:delimiter]}.*#{opts[:delimiter]}\n?/m
      
      changed = if initial.match pattern
        initial.gsub pattern, to_change
      else
        "#{initial}\n#{to_change}"
      end
      
      File.open(tmpfile.path, 'w') {|f| f.write changed}
      
      upload tmpfile.path,
             :to => file,
             :sudo => opts[:sudo]
    end

    def with_context new_context = {}, replace = false
      old_context = @context.dup
      @context = replace ? new_context : @context.merge(new_context).merge(:prefix => "#{old_context[:prefix]} #{new_context[:prefix]}")
      yield(@context).tap { @context = old_context }
    end

    def in_dir path, &block
      raise ArgumentError, 'Only absolute paths allowed' unless path[0,1] == '/'
      with_context(:path => path) do |context|
        block.call(path, context)
      end
    end

    def as_user user, &block
      with_context(:user => user, &block)
    end

    def with_prefix prefix, &block
      with_context(:prefix => prefix, &block)
    end

    def raw_exec command
      bright_p command

      result = ''

      collect_output = lambda do |data|
        result << data
        print(data)
        STDOUT.flush
      end

      main_channel = ssh.open_channel do |ch|
        ch.exec("bash -l") do |ch2, _|
          ch2.on_data { |_, data| collect_output.call(data) }

          ch2.on_extended_data { |_, _, data| collect_output.call(data) }

          ch2.send_data "export TERM=vt100\n"

          ch2.send_data "#{command}\n"

          ch2.send_data "exit\n"
        end
      end

      main_channel.wait
      main_channel.close

      result
    end

    def remote_command command
      command = "#{@context[:prefix].strip} #{command}" if @context[:prefix].present?
      command = "cd #{@context[:path]} && #{command}"   if @context[:path].present?
      command = "#{shell_command} -c \"#{command.gsub(/"/, '\"')}\""

      if @context[:user].present?
        command = "sudo -u #{@context[:user]} #{command}"
      elsif @context[:sudo]
        command = "sudo #{command}"
      end

      command
    end

    def exec command, context = {}
      with_context(context) { raw_exec(remote_command(command)) }
    end

    def shell_command
      rvm_installed? ? 'rvm-shell' : 'bash'
    end

    def sudo command = nil, &block
      block = Proc.new { exec command } unless block_given?
      with_context(:sudo => true, &block)
    end
      
    def su_exec user, command
      as_user user do
        exec command
      end
    end
      
    def in_temp_dir &block
      tmp_dirname = "/tmp/standup_tmp_#{rand 10000}"
      exec "mkdir -m 777 #{tmp_dirname}"
      result = in_dir tmp_dirname, &block
      exec "rm -rf #{tmp_dirname}"
      result
    end
      
    def file_exists? path
      exec("if [ -e #{path} ]; then echo 'true'; fi") =~ /true/
    end

    def install_packages packages, opts = {}
      input = opts[:input] ? "echo \"#{opts[:input].join("\n")}\" | sudo " : ''
      sudo "#{input}apt-get -qqy install #{packages}"
    end
    alias :install_package :install_packages
      
    def install_gem name, version = nil
      if version
        unless exec("gem list | grep #{name}").try(:[], version)
          sudo "gem install #{name} -v #{version} --no-ri --no-rdoc"
          return true
        end
      else
        sudo "gem install #{name} --no-ri --no-rdoc"
        return true
      end
      false
    end
    
    def update_cron schedule, commands, opts = {}
      raise ArgumentError, ":section option is required" unless opts[:section]
      user = opts[:user] || @node.scripts.ec2.params.ssh_user
      commands = commands.strip.split("\n") if commands.is_a? String
      commands = commands.map(&:strip).join(' && ').gsub(/%/, '\%')
    
      in_temp_dir do |dir|
        sudo "crontab -l -u #{user} > crontab.txt"
        remote_update "#{dir}/crontab.txt",
                      "#{schedule} (date && #{commands}) >> /var/log/cron.log 2>&1\n",
                      :delimiter => "# standup update_cron: #{opts[:section]}",
                      :sudo => true
        sudo "crontab -u #{user} - < crontab.txt"
      end
    end
    
    def close
      @ssh.close if @ssh
      @ssh = nil
    end
    
    def rvm_installed?
      unless instance_variable_defined? :@rvm_installed
        @rvm_installed = !!(raw_exec('which rvm') =~ /rvm/)
      end
      @rvm_installed
    end

    protected

    def ssh
      @ssh ||= Net::SSH.start @host, @user,
                              :keys => @keypair_file,
                              :paranoid => false,
                              :timeout => 10,
                              :compression => 'zlib'
    end
    
    def rsync source, destination, sudo
      command = [
        'rsync -rlptDzP --delete',
        "-e 'ssh -i #{@keypair_file} -C -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'",
        ("--rsync-path='sudo rsync'" if sudo),
        [*source].join(' '),
        destination
      ].compact.join(' ')
      
      3.times do
        bright_p command
        return true if system command
      end
      false
    end
    
    def wrap_to_remote files
      [*files].map{|f| "#{@user}@#{@host}:#{f}"}.join(' ')
    end
  end
end