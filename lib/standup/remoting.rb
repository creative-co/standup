require 'tempfile'

module Standup
  class Remoting
    def initialize node
      @node = node
      @host = @node.instance.external_ip
      @keypair_file = Settings.aws.keypair_file
      @user = @node.scripts.ec2.params.ssh_user
      @ssh = nil
      @path = nil
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
  
      download file,
               :to => tmpfile.path,
               :sudo => opts[:sudo]
  
      opts[:delimiter] ||= '# standup remote_update fragment'
      
      initial = File.read(tmpfile.path)
      
      if initial.empty?
        bright_p "error during file upload. skipping", Highline::RED
        return
      end
      
      to_change = "#{opts[:delimiter]}\n#{body}#{opts[:delimiter]}\n"
      changed = initial.gsub /#{opts[:delimiter]}.*#{opts[:delimiter]}\n?/m, to_change
      
      File.open(tmpfile.path, 'w') {|f| f.write changed}
      
      upload tmpfile.path,
             :to => file,
             :sudo => opts[:sudo]
    end
    
    def in_dir path
      raise ArgumentError, 'Only absolute paths allowed' unless path[0,1] == '/'
      old_path = @path
      @path = path
      result = yield path
      @path = old_path
      result
    end
    
    def exec command
      command  = @path ? "cd #{@path} && #{command}" : command
      bright_p command
      ssh.exec! command do |ch, _, data|
        ch[:result] ||= ""
        ch[:result] << data
        print data
        STDOUT.flush
      end
    end
      
    def sudo command
      exec "sudo #{command}"
    end
      
    def su_exec user, command
      sudo "su -c \"#{command.gsub /"/, '\"'}\" #{user}"
    end
      
    def in_temp_dir &block
      tmp_dirname = "/tmp/standup_tmp_#{rand 10000}"
      exec "mkdir #{tmp_dirname}"
      result = in_dir tmp_dirname, &block
      exec "rm -rf #{tmp_dirname}"
      result
    end
      
    def file_exists? path
      exec("if [ -e #{path} ]; then echo 'true'; fi") == "true\n"
    end
      
    def install_packages *packages
      packages = [*packages].flatten.join(' ')
      sudo "apt-get -qqy install #{packages}"
    end
    alias :install_package :install_packages
      
    def install_gem name, version = nil
      if version
        unless exec("gem list | grep #{name}").try(:[], version)
          sudo "gem install #{name} -v #{version} --no-ri --no-rdoc"
        end
      else
        sudo "gem install #{name} --no-ri --no-rdoc"
      end
    end
    
    def close
      @ssh.close if @ssh
      @ssh = nil
    end
    
    protected

    def ssh
      @ssh ||= Net::SSH.start @host, @user,
                              :keys => @keypair_file,
                              :paranoid => false,
                              :timeout => 10
    end
    
    def rsync source, destination, sudo
      command = [
        'rsync -rlptDzP --delete',
        "-e 'ssh -i #{@keypair_file} -q -o StrictHostKeyChecking=no'",
        ("--rsync-path='sudo rsync'" if sudo),
        [*source].join(' '),
        destination
      ].compact.join(' ')
      
      3.times do
        bright_p command
        break if system command
      end
    end
    
    def wrap_to_remote files
      [*files].map{|f| "#{@user}@#{@host}:#{f}"}.join(' ')
    end
  end
end