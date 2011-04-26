Standup.script :node do
  self.description = 'Update working application'
  
  def run
    in_dir scripts.webapp.app_path do
      sudo 'chown -R ubuntu:ubuntu .'
      
      pull_changes
      
      update_webapp
      
      sudo 'chown -R www-data:www-data .'
      
      restart_webapp
    end
  end
  
  protected
  
  def pull_changes
    exec 'git checkout HEAD .'
    exec 'git pull'
    exec "git checkout #{scripts.webapp.params.git_branch}"
  end
  
  def update_webapp
    scripts.webapp.install_gems
    sudo "RAILS_ENV=#{scripts.webapp.params.rails_env} rake db:migrate"
  end
  
  def restart_webapp
    sudo 'mkdir -p tmp'
    sudo 'touch tmp/restart.txt'
    scripts.delayed_job.restart if scripts.setup.has_script? 'delayed_job'
  end
end
