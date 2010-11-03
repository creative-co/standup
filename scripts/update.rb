Standup.script do
  self.description = 'Update working application'
  
  def run
    in_dir '/opt/webapp' do
      sudo 'chown -R ubuntu:ubuntu /opt/webapp'
      exec 'git pull'
      sudo 'bundle install'
      sudo 'RAILS_ENV=production rake db:migrate'
      sudo 'mkdir -p tmp'
      sudo 'chown -R nobody:nogroup /opt/webapp'
      sudo 'touch tmp/restart.txt'
    end
  end
end