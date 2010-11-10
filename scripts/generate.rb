Standup.script :local do
  self.description = 'Generate script'
  
  def run
    script_name = argument '<script name>'
    
    FileUtils.mkdir_p(Standup.local_scripts_path)
    FileUtils.copy script_file('script.rb'),
                   File.expand_path("#{script_name}.rb",  Standup.local_scripts_path)
  end
end
