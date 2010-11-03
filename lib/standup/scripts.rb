module Standup
  module Scripts; end
  
  def self.scripts
    unless class_variable_defined? :@@scripts
      @@scripts = {}
      dir = 'config/standup'
      Dir.foreach(dir) do |name|
        next unless File.file? "#{dir}/#{name}"
        next unless name =~ /\.rb$/
        load "#{dir}/#{name}", true
      end
    end
    @@scripts
  end
  
  def self.script &block
    name = block.__file__.match(/([^\/]*)\.rb$/)[1]
    script_class = Class.new(Standup::Scripts::Base, &block)
    script_class.name = name
    Standup::Scripts.const_set name.camelize, script_class
    scripts[name] = script_class
  end
end
