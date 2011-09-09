Standup.script :node do
  def run
    with_processed_file script_file('logrotate.conf.erb') do |file|
      upload file,
             :to => "/etc/logrotate.d/standup",
             :sudo => true
    end
  end
end
