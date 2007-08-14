module MatzBot::Commands
  
  raise "no!"
  
  protected
  def hax(data)    
    pm eval(data.join(" ")).inspect    
  end
end
