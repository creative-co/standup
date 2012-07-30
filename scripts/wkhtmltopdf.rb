Standup.script :node do
  def run
    return if file_exists?('/usr/local/bin/wkhtmltopdf')

    install_packages 'openssl build-essential xorg libssl-dev'

    in_temp_dir do
      #Linux ip-10-83-19-167 2.6.32-309-ec2 #18-Ubuntu SMP Mon Oct 18 21:00:20 UTC 2010 i686 GNU/Linux
      #Linux ip-10-34-41-127 2.6.32-316-ec2 #31-Ubuntu SMP Wed May 18 14:10:36 UTC 2011 x86_64 GNU/Linux
      if exec('uname -a') =~ /x86_64/
        exec 'wget http://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.9.9-static-amd64.tar.bz2'
        exec 'tar xvjf wkhtmltopdf-0.9.9-static-amd64.tar.bz2'
        sudo 'mv wkhtmltopdf-amd64 /usr/local/bin/wkhtmltopdf'
      else
        exec 'wget http://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.9.9-static-i386.tar.bz2'
        exec 'tar xvjf wkhtmltopdf-0.9.9-static-i386.tar.bz2'
        sudo 'mv wkhtmltopdf-i386 /usr/local/bin/wkhtmltopdf'
      end
    end

    sudo 'chmod +x /usr/local/bin/wkhtmltopdf'
  end
end
