Standup.script :node do
  self.description = 'Do all setup from scratch and/or incrementally'
  
  self.default_params =  'ec2 basics monit ruby postgresql passenger webapp db_backup update'
  
  def run
    params.strip.split.each do |name|
      scripts[name].put_title
      scripts[name].run
    end
  end
  
  def has_script? name
    params.strip.split.include? name
  end
end
