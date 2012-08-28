# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "standup/version"

Gem::Specification.new do |s|
  s.name        = "standup"
  s.version     = Standup::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ilia Ablamonov", "Artem Orlov", "Cloud Castle Inc."]
  s.email       = ["ilia@flamefork.ru", "art.orlov@gmail.com"]
  s.homepage    = "https://github.com/cloudcastle/standup"
  s.summary     = %q{Standup is an application deployment and infrastructure management tool for Rails and Amazon EC2}
  s.description = %q{}

  s.rubyforge_project = "standup"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'trollop', '>= 1.16'
  s.add_dependency 'i18n', '>= 0.5.0'
  s.add_dependency 'activesupport', '>= 3.0'
  s.add_dependency 'settingslogic', '>= 2.0'
  s.add_dependency 'amazon-ec2', '>= 0.9'
  s.add_dependency 'aws-s3', '>= 0.5'
  s.add_dependency 'net-ssh', '>= 2.0'
  s.add_dependency 'highline', '>= 1.5.2'
  s.add_dependency 'octokit', '>= 1.10.0'
end