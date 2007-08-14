module MatzBot::Commands

  COW_OPTIONS = %[borg dead paranoid stoned tired wired young]
  help_method :cow => [:cowsay, :cowthink]
  
  def cowsay data
    cow :say, data
  end
  def cowthink data
    cow :think, data
  end
  
  private
  def cow o, data
    flag = ("-#{data.shift[0..0]}" if COW_OPTIONS.include? data.first)
    IO.popen("cow#{o} #{flag}", "r+") do |p|
      p.puts data.join(" ")
      p.close_write
      say p.read
    end
  end
end
