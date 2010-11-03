Standup.script do
  self.description = 'Generate script'
  
  def run
    unless ENV['SCRIPT']
      bright_p "Specify script name with SCRIPT=name argument"
      return
    end
    
    FileUtils.mkdir_p(Standup.local_scripts_path)
    FileUtils.copy script_file('script.rb'),
                   File.expand_path("#{ENV['SCRIPT']}.rb",  Standup.local_scripts_path)
  end
end
