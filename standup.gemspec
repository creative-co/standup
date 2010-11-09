# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{standup}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ilia Ablamonov", "Cloud Castle Inc."]
  s.date = %q{2010-11-10}
  s.default_executable = %q{standup}
  s.email = %q{ilia@flamefork.ru}
  s.executables = ["standup"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.md"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.md",
     "Rakefile",
     "VERSION",
     "bin/standup",
     "lib/standup.rb",
     "lib/standup/core_ext.rb",
     "lib/standup/ec2.rb",
     "lib/standup/ec2/base.rb",
     "lib/standup/ec2/elastic_ip.rb",
     "lib/standup/ec2/instance.rb",
     "lib/standup/ec2/security_group.rb",
     "lib/standup/ec2/volume.rb",
     "lib/standup/node.rb",
     "lib/standup/remoting.rb",
     "lib/standup/scripts/base.rb",
     "lib/standup/settings.rb",
     "scripts/allocate_ip.rb",
     "scripts/appconsole.rb",
     "scripts/basics.rb",
     "scripts/ec2.rb",
     "scripts/generate.rb",
     "scripts/generate/script.rb",
     "scripts/init.rb",
     "scripts/init/standup.yml",
     "scripts/localize.rb",
     "scripts/passenger.rb",
     "scripts/passenger/nginx.conf",
     "scripts/passenger/upstart.conf",
     "scripts/postgresql.rb",
     "scripts/postgresql/postgresql.conf",
     "scripts/ruby.rb",
     "scripts/setup.rb",
     "scripts/shell.rb",
     "scripts/status.rb",
     "scripts/terminate.rb",
     "scripts/update.rb",
     "scripts/webapp.rb",
     "scripts/webapp/nginx-server-fragment.conf",
     "standup.gemspec"
  ]
  s.homepage = %q{http://github.com/Flamefork/standup}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Standup is an application deployment and infrastructure management tool for Rails and Amazon EC2}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<trollop>, [">= 1.16"])
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0"])
      s.add_runtime_dependency(%q<settingslogic>, [">= 2.0"])
      s.add_runtime_dependency(%q<amazon-ec2>, [">= 0.9"])
      s.add_runtime_dependency(%q<aws-s3>, [">= 0.5"])
      s.add_runtime_dependency(%q<net-ssh>, [">= 2.0"])
      s.add_runtime_dependency(%q<highline>, [">= 1.5.2"])
    else
      s.add_dependency(%q<trollop>, [">= 1.16"])
      s.add_dependency(%q<activesupport>, [">= 3.0"])
      s.add_dependency(%q<settingslogic>, [">= 2.0"])
      s.add_dependency(%q<amazon-ec2>, [">= 0.9"])
      s.add_dependency(%q<aws-s3>, [">= 0.5"])
      s.add_dependency(%q<net-ssh>, [">= 2.0"])
      s.add_dependency(%q<highline>, [">= 1.5.2"])
    end
  else
    s.add_dependency(%q<trollop>, [">= 1.16"])
    s.add_dependency(%q<activesupport>, [">= 3.0"])
    s.add_dependency(%q<settingslogic>, [">= 2.0"])
    s.add_dependency(%q<amazon-ec2>, [">= 0.9"])
    s.add_dependency(%q<aws-s3>, [">= 0.5"])
    s.add_dependency(%q<net-ssh>, [">= 2.0"])
    s.add_dependency(%q<highline>, [">= 1.5.2"])
  end
end

