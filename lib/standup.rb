require 'active_support/all'
require 'settingslogic'
require 'AWS'
require 'aws/s3'
require 'net/ssh'
require 'highline'
require 'trollop'

require 'standup/core_ext'
require 'standup/settings'
require 'standup/ec2'
require 'standup/remoting'
require 'standup/scripts/base'
require 'standup/scripts/node'
require 'standup/node'
require 'standup/version'

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

  def self.conf_scripts_path
    File.expand_path("#{Settings.conf_scripts_path}/config/standup") rescue nil
  end
  
  def self.scripts
    unless class_variable_defined? :@@scripts
      @@scripts = {}
      [gem_scripts_path, conf_scripts_path, local_scripts_path].compact.each do |dir|
        Dir.foreach dir do |name|
          next unless File.file? "#{dir}/#{name}"
          next unless name =~ /\.rb$/
          load "#{dir}/#{name}", true
        end if dir && File.exists?(dir)
      end
    end
    @@scripts
  end

  def self.script type = :node, &block
    name = eval("__FILE__", block.binding).match(/([^\/]*)\.rb$/)[1]
    superclass = scripts[name] || case type
      when :node
        Scripts::Node
      when :local
        Scripts::Base
      else
        raise ArgumentError, "Unknown script type #{type}"
    end
    script_class = Class.new(superclass, &block)
    script_class.name = name
    Standup::Scripts.send(:remove_const, name.camelize) if scripts[name]
    Standup::Scripts.const_set name.camelize, script_class
    scripts[name] = script_class
  end

  def self.run_from_command_line
    if File.exists?('Gemfile') && !ENV['BUNDLE_GEMFILE']
      Kernel.exec "bundle exec standup #{ARGV.join(' ')}"
    end
    
    opt_parser = Trollop::Parser.new do
      version "Standup #{Standup.version} (c) 2010 Ilia Ablamonov, Artem Orlov, Cloud Castle Inc."
  
      banner 'Standup is an application deployment and infrastructure management tool for Rails and Amazon EC2.'
      banner ''
      banner 'Usage:'
      banner '       standup [options] <script> [script arguments]'
      banner ''
      banner 'where <script> is one of the following:'
      banner ''
  
      offset = Standup.scripts.keys.map(&:length).max + 2
      Standup.scripts.keys.sort.each do |name|
        banner "#{"%-#{offset}s" % name} #{Standup.scripts[name].description}"
      end
  
      banner ''
      banner "and [options] are:"
      banner ''
  
      stop_on Standup.scripts.keys
    end

    Trollop::with_standard_exception_handling opt_parser do
     opt_parser.parse ARGV
     raise Trollop::HelpNeeded if ARGV.empty?
    end

    script_name = ARGV.shift
    script = Standup.scripts[script_name]

    if script
      script.execute
    else
      opt_parser.die "unknown script #{script_name}", nil
    end
  end
end
