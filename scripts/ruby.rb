Standup.script :node do
  self.default_params = {
      :rvm_ruby_version => '1.9.2'
  }

  def run
    if Standup::Settings.use_rvm
      setup_rvm
    else
      setup_ree
    end
  end

  def setup_rvm
    return if remoting.rvm_installed?

    install_package 'git-core'

    sudo 'bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)'

    exec "rvm install #{params.rvm_ruby_version}"

    exec "rvm use #{params.rvm_ruby_version} --default"

    remoting.instance_variable_set :@rvm_installed, nil
  end

  def setup_ree
    return if exec('ruby -v') =~ /Ruby Enterprise Edition 2010.02/

    in_temp_dir do
      arch64 = instance.architecture =~ /64/
      filename = "ruby-enterprise_1.8.7-2010.02_#{arch64 ? 'amd64' : 'i386'}_ubuntu10.04.deb"
      exec "wget -q http://rubyforge.org/frs/download.php/#{arch64 ? '71098' : '71100'}/#{filename}"
      sudo "dpkg -i #{filename}"
    end
  end
end
