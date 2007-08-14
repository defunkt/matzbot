module MatzBot::Commands
  def seen(data)
    nick = data.join(" ")
    history = `tail -n 4000 chat.txt`.split("\n").reverse
    if nick == config[:nick]
      say "I'm right here, jerkface."
    else
      result = history.find {|line| line =~ /\<#{nick}\>/ }
      if result
        puts "I last saw #{nick} saying:"
        puts result
      else
        puts "I haven't seen #{nick} recently."
      end
    end
  end
end
