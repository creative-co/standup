Standup.script :node do
  def run
    return if remoting.rvm_installed?
    
    install_package 'git-core'
    
    sudo 'bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)'
    
    exec "rvm install #{version}"
    exec "rvm use #{version} --default"
    
    sudo 'usermod -a -G rvm www-data'
    
    remoting.instance_variable_set :@rvm_installed, true
  end

  def version
    @version ||= begin
      files = Dir['**/.rvmrc']

      if files.empty?
        if params.version.present?
          params.version
        else
          puts "Cannot fine ruby version declaration neither in .rvmrc file or ruby script param"
          raise Exception.new('Cannot find ruby version declaration')
        end
      else
        declarations = files.map do |file|
          if (rvm_declaration = IO.read(file)).index('rvm') == 0
            rvm_declaration.split(' ').second.split('@').first
          else
            puts "Cannot parse .rvmrc declaration:\n#{rvm_declaration}"
            raise Exception.new("Cannot parse #{file}")
          end
        end.uniq

        if declarations.size > 1
          puts "Found different ruby version declarations #{declarations}"
          if params.version.present?
            params.version
          else
            raise Exception.new('Several ruby version declarations found')
          end
        else
          declarations.first
        end
      end
    end
  end
end
