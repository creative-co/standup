Standup.script :node do
  self.description = 'Update web application'
  
  def run
    in_dir scripts.webapp.project_path do
      sudo 'chown -R ubuntu:ubuntu .'
      exec 'git checkout HEAD .'
      exec 'git pull'
    end

    scripts.webapp.checkout_branch

    update_webapp

    sudo "chown -R www-data:www-data #{scripts.webapp.project_path}"

    scripts.webapp.restart
  end
  
  protected
  
  def update_webapp
    scripts.webapp.install_gems
    
    in_dir scripts.webapp.app_path do
      sudo "RAILS_ENV=#{scripts.webapp.params.rails_env} rake db:migrate"
    end
  end
end
