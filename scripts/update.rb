Standup.script :node do
  self.description = 'Update working application'
  
  def run
    in_dir scripts.webapp.app_path do
      sudo 'chown -R ubuntu:ubuntu .'
      exec 'git pull'
      sudo 'bundle install'
      sudo "RAILS_ENV=#{scripts.webapp.params.rails_env} rake db:migrate"
      sudo 'mkdir -p tmp'
      sudo 'chown -R nobody:nogroup .'
      sudo 'touch tmp/restart.txt'
      scripts.delayed_job.restart if scripts.setup.has_script? 'delayed_job'
    end
  end
end