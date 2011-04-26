Standup.script :local do
  self.description = 'Put specified script into project configuration'
  
  def run
    variants = Standup.scripts.keys.sort.select{|script_name| File.exists? File.expand_path("#{script_name}.rb", Standup.gem_scripts_path)}
    script_name = argument '<script name>', 'script name', variants
    
    FileUtils.mkdir_p(Standup.local_scripts_path)
    [script_name, "#{script_name}.rb"].each do |path|
      path = File.expand_path(path, Standup.gem_scripts_path)
      if File.exists? path
        FileUtils.cp_r path, Standup.local_scripts_path
      end
    end
  end
end
