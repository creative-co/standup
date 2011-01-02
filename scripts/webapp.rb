Standup.script :node do
  self.default_params = {
      :rails_env => 'production',
      :name => 'webapp',
      :server_name => '_'
  }

  def run
    install_package 'git-core'
    install_gem 'bundler'
    install_package params.additional_packages if params.additional_packages.present?

    unless file_exists? scripts.webapp.app_path
      sudo "mkdir -p #{scripts.webapp.app_path}"
    end

    sudo "chown -R ubuntu:ubuntu #{scripts.webapp.app_path}"

    ensure_github_access

    unless file_exists? "#{scripts.webapp.app_path}/.git"
      exec "rm -rf #{scripts.webapp.app_path}/*"
      exec "git clone git@github.com:#{github_repo}.git #{scripts.webapp.app_path}"
    end

    bootstrap_db

    sudo "chown -R www-data:www-data #{scripts.webapp.app_path}"

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

  protected
  
  def ensure_github_access
    return unless exec('ssh -o StrictHostKeyChecking=no git@github.com') =~ /Permission denied \(publickey\)/

    unless file_exists? '~/.ssh/id_rsa'
      exec "ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' -C `hostname`"
    end

    password = bright_ask("Enter GitGub password for user #{params.github_user}:", false)

    github_add_deploy_key params.github_user,
                          password,
                          github_repo,
                          exec('hostname').strip,
                          exec('cat ~/.ssh/id_rsa.pub').strip
  end

  def bootstrap_db
    if db.create_database db_name
      in_dir scripts.webapp.app_path do
        sudo 'bundle install'
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
