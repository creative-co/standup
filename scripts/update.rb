Standup.script :node do
  self.description = 'Update web application'
  
  def run
    in_dir scripts.webapp.project_path do
      sudo 'chown -R ubuntu:ubuntu .'

      exec 'git checkout HEAD .'
      exec 'git pull'

      scripts.webapp.checkout_branch

      sudo "chown -R www-data:www-data ."
    end

    update_webapp

    scripts.webapp.restart
  end
  
  protected
  
  def update_webapp
    scripts.webapp.install_gems

    scripts.webapp.with_environment do
      exec 'rake db:migrate'
    end
  end
end
