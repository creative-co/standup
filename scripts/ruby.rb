Standup.script :node do
  self.default_params = {
      :version => '1.9.2'
  }

  def run
    return if remoting.rvm_installed?

    install_package 'git-core'

    sudo 'bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)'

    exec "rvm install #{params.version}"
    exec "rvm use #{params.version} --default"
    
    remoting.instance_variable_set :@rvm_installed, true
  end
end
