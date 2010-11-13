Standup.script :node do
  self.default_params = {
      :rails_env => 'production'
  }
  
  def run
    install_package 'git-core'
    install_gem 'bundler'
    
    unless file_exists? '/opt/webapp'
      sudo 'mkdir -p /opt/webapp'
    end
    
    sudo 'chown -R ubuntu:ubuntu /opt/webapp'
    
    ensure_github_access
    
    unless file_exists? '/opt/webapp/.git'
      exec 'rm -rf /opt/webapp/*'
      exec "git clone git@github.com:#{params.github_user}/#{params.github_repo}.git /opt/webapp"
    end

    bootstrap_db

    sudo 'chown -R nobody:nogroup /opt/webapp'
    
    scripts.passenger.add_server_conf script_file('webapp.conf')
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
                          params.github_repo,
                          exec('hostname').strip,
                          exec('cat ~/.ssh/id_rsa.pub').strip
  end
  
  def bootstrap_db
    unless run_pg_command("select * from pg_user where usename = 'webapp'") =~ /1 row/
      run_pg_command "create user webapp with password 'webapp'"
    end
    
    unless run_pg_command("select * from pg_database where datname = 'webapp'") =~ /1 row/
      run_pg_command "create database webapp with owner webapp"
      
      in_dir '/opt/webapp' do
        sudo 'bundle install'
        exec "RAILS_ENV=#{params.rails_env} rake db:schema:load"
        exec "RAILS_ENV=#{params.rails_env} rake db:seed"
      end
    end
  end
  
  def run_pg_command cmd
    sudo("su -c \"psql -c \\\"#{cmd}\\\"\" postgres")
  end
  
  def github_add_deploy_key user, password, repo, title, key
    require 'net/http'
    Net::HTTP.start 'github.com' do |http|
      req = Net::HTTP::Post.new "/api/v2/json/repos/key/#{user}/#{repo}/add"
      req.form_data = {'title' => title, 'key' => key}
      req.basic_auth user, password
      response = http.request req
      response.is_a? Net::HTTPSuccess
    end
  end
end
