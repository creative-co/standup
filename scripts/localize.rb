Standup.script do
  self.description = 'Put specified script into project configuration'
  
  def run
    unless ENV['SCRIPT']
      bright_p "Specify script name with SCRIPT=name argument"
      return
    end
    
    FileUtils.mkdir_p(Standup.local_scripts_path)
    [ENV['SCRIPT'], "#{ENV['SCRIPT']}.rb"].each do |path|
      path = File.expand_path(path, Standup.gem_scripts_path)
      if File.exists? path
        FileUtils.cp_r path, Standup.local_scripts_path
      end
    end
  end
end
