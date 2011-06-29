Standup.script :node do
  self.default_params = {
      :version => '1.9.2'
  }

  def run
    return if remoting.rvm_installed?

    install_package 'git-core'

    sudo 'bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)'

    exec "rvm install #{version}"
    exec "rvm use #{version} --default"

    remoting.instance_variable_set :@rvm_installed, true
  end

  def version
    @version ||= begin
      if File.exists?('.rvmrc')
        rvm_declaration = IO.read('.rvmrc')
        if rvm_declaration.index('rvm') == 0
          rvm_declaration.split(' ').second
        else
          puts "Cannot parse .rvmrc declaration:\n#{rvm_declaration}"
          params.version
        end
      else
        params.version
      end
    end
  end
end
