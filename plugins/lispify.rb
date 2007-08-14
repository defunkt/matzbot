module MatzBot::Commands
  def lispify(data)
#    puts data.join(" ").gsub(/(..)/) { |s| s + (rand(2).zero? ? ") " : " (") }
    puts data.join(" ").gsub(/s+/, "th")
  end
end
