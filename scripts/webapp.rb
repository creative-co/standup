Standup.script :node do
  self.default_params = {
      :rails_env => 'production',
      :name => 'webapp',
      :server_name => '_',
      :git_branch => 'master',
      :gem_manager => :bundler,
      :bootstrap_db => false,
      :app_subdir => ''
  }

  def run
    install_package 'git-core'
    install_package params.additional_packages if params.additional_packages.present?

    unless file_exists? project_path
      sudo "mkdir -p #{project_path}"
    end

    sudo "chown -R ubuntu:ubuntu #{project_path}"

    ensure_github_access

    unless file_exists? "#{project_path}/.git"
      exec "rm -rf #{project_path}/*"
      exec "git clone git@github.com:#{github_repo}.git #{project_path}"
    end

    checkout_branch

    sudo "chown -R www-data:www-data #{app_path}"

    install_gems

    bootstrap_db if params.bootstrap_db

    with_processed_file script_file('webapp.conf') do |file|
      scripts.passenger.add_server_conf file, "#{params.name}.conf"
    end
  end

  def with_environment
    with_context(:user => 'www-data', :path => app_path, :prefix => "RAILS_ENV=#{params.rails_env} bundle exec") do
      yield
    end
  end

  def project_path
    "/opt/#{params.name}"
  end
  
  def app_path
    File.join(project_path, params.app_subdir)
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
    with_context(:user => 'www-data', :path => app_path) do
      case params.gem_manager.to_sym
        when :bundler
          install_gem 'bundler'
          exec 'bundle install'
        when :rake_gems
          cmd = "RAILS_ENV=#{params.rails_env} rake gems:install"
          output = exec cmd
          if output.match(/Missing the Rails ([\d\.]+) gem/) || output.match(/RubyGem version error: rails\([\d\.]+ not = ([\d\.]+)\)/)
            install_gem 'rails', $1
            exec cmd
          end
      end
    end
  end

  def checkout_branch
    in_dir project_path do
      exec "git checkout #{params.git_branch}"
    end
  end

  def restart
    in_dir app_path do
      sudo 'mkdir -p tmp'
      sudo 'touch tmp/restart.txt'
      scripts.delayed_job.restart if scripts.setup.has_script? 'delayed_job'
      scripts.resque.restart      if scripts.setup.has_script? 'resque'
    end
  end

  protected
  
  def ensure_github_access
    unless file_exists? '~/.ssh/id_rsa'
      exec "ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' -C `hostname`"
    end
    
    while exec('ssh -o StrictHostKeyChecking=no git@github.com') =~ /Permission denied \(publickey\)/
      password = bright_ask("Enter GitGub password for user #{params.github_user}:", false)

      github_add_deploy_key params.github_user,
                            password,
                            github_repo,
                            exec('hostname').strip,
                            exec('cat ~/.ssh/id_rsa.pub').strip
    end
  end

  def bootstrap_db
    if db.create_database db_name
      with_environment do
        exec "rake db:schema:load"
        exec "rake db:seed"
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
