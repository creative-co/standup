require 'settingslogic'
require 'AWS'
require 'aws/s3'
require 'net/ssh'
require 'highline'

require 'standup/settings'
require 'standup/ec2'
require 'standup/remoting'
require 'standup/scripts'
require 'standup/scripts/base'
require 'standup/node'

module Kernel
  def bright_p message, color = ''
    puts "\e[1m#{color}#{message}\e[0m"
  end
  
  def bright_ask message, echo = true
    require 'highline'
    bright_p message, HighLine::GREEN
    HighLine.new.ask('') {|q| q.echo = echo}
  end
end

module Standup
  def self.nodes
    Settings.nodes.keys.map{|name| Node.new name}
  end
end