module MatzBot::Commands
  needs_gem 'linguistics' => :count

  def count(data)
    Linguistics.use(:en)

    if data.first == 'slow'
      data.shift
      slow = true
    else
      slow = false
    end

    case data.shift
    when 'to'
      bot = 0
      top = data.shift.to_i
    when 'from'
      bot = data.shift.to_i 
      top = data[1].to_i
    end

    raise if (top - bot).abs > 20

    if top < bot
      range = (top..bot).to_a.reverse
    else
      range = (bot..top).to_a
    end

    words = range.map { |i| i.en.numwords }

    if slow
      words.each { |word| say word }
    else
      say words
    end
  rescue
    say "I don't think so."
  end
end
