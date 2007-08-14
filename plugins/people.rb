module MatzBot::Commands
  help_method :people => [ :defunkt, :hank ]

  def defunkt(data)    
    puts "i'm defunkt der der guru der der der"
  end

  def hank(data)    
    6.times do
     rand(2).times { puts "HANK!! THE SCREEN IS SCROLLING!" }
      sleep(rand(1))
      rand(4).times { puts "Hank! " * (rand(3) + 1) }
      sleep(rand(1))
    end
  end
  
  def hammer(data)
    10.times do
      sleep(1)
      say "bang!"
    end
  end
  
end
