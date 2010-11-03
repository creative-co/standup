require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'standup'
    gem.summary = %Q{Standup is an application deployment and infrastructure management tool for Rails and Amazon EC2}
    gem.description = %Q{}
    gem.email = 'ilia@flamefork.ru'
    gem.homepage = 'http://github.com/Flamefork/standup'
    gem.authors = ['Ilia Ablamonov', 'Cloud Castle Inc.']
    gem.add_dependency 'settingslogic', '>= 2.0'
    gem.add_dependency 'amazon-ec2', '>= 0.9'
    gem.add_dependency 'aws-s3', '>= 0.5'
    gem.add_dependency 'net-ssh', '>= 2.0'
    gem.add_dependency 'highline', '>= 1.5.2'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
