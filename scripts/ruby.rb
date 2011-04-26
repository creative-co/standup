Standup.script :node do
  def run
    return if exec('ruby -v') =~ /Ruby Enterprise Edition 2010.02/
    
    in_temp_dir do
      arch64 = instance.architecture =~ /64/
      filename = "ruby-enterprise_1.8.7-2010.02_#{arch64 ? 'amd64' : 'i386'}_ubuntu10.04.deb"
      exec "wget -q http://rubyforge.org/frs/download.php/#{arch64 ? '71098' : '71100'}/#{filename}"
      sudo "dpkg -i #{filename}"
    end
  end
end
