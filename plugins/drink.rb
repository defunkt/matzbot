module MatzBot::Commands
  filter :say => :drunk_talk

  def drink(data)
    drinks = ["has a beer", "thanks!", "has another beer", "thanks man",
              "has a margarita", "not enough lime :(", "has a beer", "dude this rocks", 
              "throws back a 3 wiseman", "woooooooo",
              "drinks something", "hey i don't think i should drive", 
              "slips", "hey sexy bot", "falls over", "omg help me people"]
                
    if (session[:drunkenness] ||=0) >= drinks.length
      say ["blarrrahghh", "blawauuuagh", "bruagh"][rand(3)] 
    else
      action drinks[session[:drunkenness]]
      say drinks[session[:drunkenness] + 1]
      session[:drunkenness] += 2
    end
  end
  
  def get_sober(data)
    session[:drunkenness] = 0
    say "ohhhh, my head..."
    action "takes some advil"
  end

  def drunkness(data)
    say session[:drunkenness].to_s
  end

private
  def drunk_talk(message)
    session[:drunkenness] ||= 0
    return message unless session[:drunkenness].nonzero?
    message.split("").map do |c|
      rand(60) < session[:drunkenness] ? ['l','r','c','z','b','m','s'][rand(7)] : c
    end.join
  end
end
