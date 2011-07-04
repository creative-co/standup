Standup.script :node do
  self.description = 'Run remote Rails application console'
  
  def run
    scripts.webapp.with_environment do
      exec 'rails console'
    end
  end
end
