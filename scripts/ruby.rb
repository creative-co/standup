Standup.script :node do
  def run
    install_packages 'build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev'
    build_ruby
    setup_env
  end
  
  def build_ruby
    return if exec('ruby -v') =~ /#{version.gsub(/-/, '')}/
    
    install_ruby_build
    
    sudo "CONFIGURE_OPTS='--disable-install-rdoc' ruby-build #{version} /usr/local" 
  end
  
  def install_ruby_build
    return if file_exists? '/usr/local/bin/ruby-build'
    in_temp_dir do |path|
      exec 'git clone git://github.com/sstephenson/ruby-build.git'
      in_dir "#{path}/ruby-build" do
        sudo './install.sh'
      end
    end
  end
  
  def setup_env
    upload script_file('gemrc'),
           :to => '/etc/gemrc',
           :sudo => true
  end
  
  def gems_dir
    "#{exec('gem environment gemdir').strip}/gems"
  end
  
  def version
    @version ||= begin
      versions = ([params.version] + rbenv_versions + rvm_versions).compact.uniq
      
      if versions.size == 1
        versions.first
      else
        raise "Found different ruby version declarations #{versions}"
      end
    end
  end
  
  def rvm_versions
    Dir['**/.rvmrc'].map do |f|
      if (rvm_declaration = IO.read(f)).index('rvm') == 0
        rvm_declaration.split(' ').second.split('@').first
      else
        puts "Cannot parse .rvmrc declaration:\n#{rvm_declaration}"
        raise Exception.new("Cannot parse #{f}")
      end
    end
  end
  
  def rbenv_versions
    Dir['**/.rbenv-version'].map{|f| IO.read(f).strip}
  end
end
