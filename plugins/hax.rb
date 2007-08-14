module MatzBot::Commands
  protected
  def hax(data)    
    pm eval(data.join(" ")).inspect    
  end
end
