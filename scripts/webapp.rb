Standup.script :node do
  self.default_params = {
      :rails_env => 'production',
      :name => 'webapp',
      :server_name => '_',
      :git_branch => 'master',
      :gem_manager => :bundler
  }

  option :github_password,
         :type => :password,
         :description => 'GitHub password of project owner'

  def run
    install_package 'git-core'
    install_package params.additional_packages if params.additional_packages.present?

    unless file_exists? app_path
      sudo "mkdir -p #{app_path}"
    end

    sudo "chown -R ubuntu:ubuntu #{app_path}"

    ensure_github_access

    unless file_exists? "#{app_path}/.git"
      exec "rm -rf #{app_path}/*"
      exec "git clone git@github.com:#{github_repo}.git #{app_path}"
    end
    
    in_dir app_path do
      exec "git checkout #{params.git_branch}"
    end

    install_gems

    bootstrap_db

    sudo "chown -R www-data:www-data #{app_path}"

    with_processed_file script_file('webapp.conf') do |file|
      scripts.passenger.add_server_conf file, "#{params.name}.conf"
    end
  end

  def app_path
    "/opt/#{params.name}"
  end
  
  def db_name
    "#{params.name}_#{params.rails_env}"
  end
  
  def db
    return scripts.postgresql if scripts.setup.has_script? 'postgresql'
    return scripts.mysql if scripts.setup.has_script? 'mysql'
    nil
  end
  
  def server_names
    params.server_names || params.server_name
  end

  def server_name
    server_names.split(' ').first
  end
  
  def install_gems
    in_dir app_path do
      case params.gem_manager.to_sym
        when :bundler
          install_gem 'bundler'
          exec 'bundle install'
        when :rake_gems
          cmd = "RAILS_ENV=#{params.rails_env} rake gems:install"
          if exec(cmd).match(/Missing the Rails ([\d\.]+) gem/)
            install_gem 'rails', $1
            exec(cmd)
          end
      end
    end
  end

  protected
  
  def ensure_github_access
    return unless exec('ssh -o StrictHostKeyChecking=no git@github.com') =~ /Permission denied \(publickey\)/

    unless file_exists? '~/.ssh/id_rsa'
      exec "ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' -C `hostname`"
    end

    password = get_option :github_password, "Enter GitGub password for user #{params.github_user}:"

    github_add_deploy_key params.github_user,
                          password,
                          github_repo,
                          exec('hostname').strip,
                          exec('cat ~/.ssh/id_rsa.pub').strip
  end

  def bootstrap_db
    if db.create_database db_name
      in_dir app_path do
        exec "RAILS_ENV=#{params.rails_env} rake db:schema:load"
        exec "RAILS_ENV=#{params.rails_env} rake db:seed"
      end
    end
  end

  def github_repo
    params.github_repo.include?('/') ? params.github_repo : "#{params.github_user}/#{params.github_repo}"
  end

  def github_add_deploy_key user, password, repo, title, key
    require 'net/http'
    Net::HTTP.start 'github.com' do |http|
      req = Net::HTTP::Post.new "/api/v2/json/repos/key/#{repo}/add"
      req.form_data = {'title' => title, 'key' => key}
      req.basic_auth user, password
      response = http.request req
      response.is_a? Net::HTTPSuccess
    end
  end
end
