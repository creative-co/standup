require 'active_support/all'
require 'settingslogic'
require 'AWS'
require 'aws/s3'
require 'net/ssh'
require 'highline'

require 'standup/core_ext'
require 'standup/settings'
require 'standup/ec2'
require 'standup/remoting'
require 'standup/scripts/base'
require 'standup/scripts/node'
require 'standup/node'

module Standup
  module Scripts; end
  
  def self.nodes
    Settings.nodes.keys.map{|name| Node.new name}
  end
  
  def self.gem_scripts_path
    File.expand_path('../../scripts',  __FILE__)
  end
  
  def self.local_scripts_path
    File.expand_path('config/standup') rescue nil
  end
  
  def self.scripts
    unless class_variable_defined? :@@scripts
      @@scripts = {}
      loaded = Set.new
      [local_scripts_path, gem_scripts_path].each do |dir|
        Dir.foreach dir do |name|
          next unless File.file? "#{dir}/#{name}"
          next unless name =~ /\.rb$/
          next if loaded.include? name
          load "#{dir}/#{name}", true
          loaded << name
        end if dir && File.exists?(dir)
      end
    end
    @@scripts
  end
  
  def self.script type = :node, &block
    name = block.__file__.match(/([^\/]*)\.rb$/)[1]
    superclass = case type
      when :node
        Scripts::Node
      when :local
        Scripts::Base
      else
        raise ArgumentError, "Unknown script type #{type}"
    end
    script_class = Class.new(superclass, &block)
    script_class.name = name
    Standup::Scripts.const_set name.camelize, script_class
    scripts[name] = script_class
  end
  
  def self.version
    File.read(File.expand_path('../../VERSION',  __FILE__)).strip
  end
end