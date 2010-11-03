Standup.script do
  self.description = 'Do all setup from scratch and/or incrementally'
  
  self.default_params =  'ec2 basics ruby postgresql passenger webapp update'
  
  def run
    params.strip.split.each do |name|
      scripts[name].titled_run
    end
  end
end
