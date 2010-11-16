Standup.script :node do
  def run
    sudo 'apt-get -qq update'
    install_packages 'build-essential libreadline5-dev mc s3cmd'
    
    with_processed_file script_file('s3cfg') do |file|
      upload file,
             :to => "/home/#{scripts.ec2.params.ssh_user}/.s3cfg"
    end
  end
end
