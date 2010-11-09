Standup.script do
  self.description = 'Generate config file'
  
  def run
    FileUtils.copy script_file('standup.yml'), File.expand_path('config')
  end
end
