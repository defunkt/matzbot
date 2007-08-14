module MatzBot::Commands
  filter :listen => :eightball
  
  private
  
  def eightball(message)
    answers = [
      "Yeah probably.",
      "Yes.",
      "Totally.",
      "Without a doubt.",
      "I think so.",
      "Seems that way.",
      "You can take it to the #{config[:nick]}-bank.",
      "Yep.",
      "Completely.",
      "It is decidedly so.",
      "Not really sure.",
      "It's a secret.",
      "I can't say or I will be killed.",
      "Ceiling cat says no.",
      "No clue.",
      "Probably not.",
      "I doubt it.",
      "Definitely not.",
      "No, sorry.",
      "Of course not."
    ]

    if message.strip[-1..-1] == '?' and (rand(10).zero? or message =~ /^#{config[:nick]}/i)
      say answers[message.hash % answers.size].downcase[0..-2]
    end
  end
end
