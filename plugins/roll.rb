module MatzBot::Commands
  def roll(data)
    if data.first =~ /(\d+)d(\d*)/
      sides = $2.empty? ? 6 : $2.to_i
      return puts("No.") if sides > 100 || $1.to_i > 100
      roll = Range.new(0, $1.to_i).inject { |m, i| m += (rand(sides) + 1) }
      action "rolls #{$1} #{sides} sided dice and gets a #{roll}."
    else
      action "rolls a six sided die and gets a #{rand(6)+1}."
    end
  end
end
