module Kernel
  def bright_p message, color = ''
    puts "\e[1m#{color}#{message}\e[0m"
  end
  
  def bright_ask message, echo = true
    bright_p message, HighLine::GREEN
    HighLine.new.ask('') {|q| q.echo = echo}
  end
  
  def local_exec command
    bright_p command
    `#{command} 2>&1`.tap{|result| puts result}
  end
end
