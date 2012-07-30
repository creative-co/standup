Standup.script :node do
  self.description = 'Do all setup from scratch and/or incrementally'
  
  self.default_params =  'ec2 basics monit ruby postgresql passenger webapp db_backup update'
  
  def self.execute
    Standup.nodes.each do |node|
      node.scripts.setup.setup_scripts.each do |sname|
        Standup.scripts[sname].options.each do |oname, opts|
          next if oname == 'nodes'
          option :"#{sname}-#{oname}", opts.merge({:description => "[#{sname}] #{opts[:description]}", :short => :none})
        end
      end
    end
    
    super
  end
  
  def run
    setup_scripts.each do |name|
      script = scripts[name]
      
      script.class.set_options self.class.get_options.map{|k,v| k.to_s.match(/^#{name}-(.*)/) ? [$1, v] : nil}.select(&:present?).map_to_hash{|k,v| {k.to_sym => v}}
      
      script.put_title
      script.run
    end
  end
  
  def has_script? name
    setup_scripts.include? name
  end
  
  def setup_scripts
    params.strip.split
  end
end
