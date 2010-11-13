Standup.script :node do
  self.description = 'Open Web browser with specified node address'
  
  def run
    return unless node.instance
    ['x-www-browser', 'open'].each do |cmd|
      if `which #{cmd}`.present?
        `#{cmd} http://#{node.instance.external_ip}/`
        return
      end
    end
  end
end
