Standup.script :node do
  def run
    sudo 'apt-get -qq update'
    install_packages 'build-essential libreadline5-dev mc'
  end
end
