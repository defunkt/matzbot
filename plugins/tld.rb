require 'yaml'
require 'pathname'

module MatzBot::Commands
  TLDS = YAML.load_file(Pathname.new(__FILE__).dirname.to_s + '/tld.yml')
  STANDARD_TLDS = %w[com org net]
  WHOIS_SPECIAL_NXDOMAINS = {'st' => "No entries found for", 
                                                    'sh' => "To purchase please go to"}

  LETTERS = (?a..?z).to_a.map{|c| c.chr}
  NUMBERS = (0..9).to_a.map{|i| i.to_s}
  
  def dhax data
    if data.empty?
      say ">> dhax prefix" 
      say "thinks up real web 2.0-style domains for your prefix" 
   else
      data.each do |word|
        results = []
        [word, word[0..-2], word[0..-3]].each do |domain|
          next if word.empty?
          realwords = (Hpricot(open("http://www.morewords.com/?#{domain}*").read)/:li).map{|n| (n/:a).innerHTML}
          tlds = TLDS.keys.map{|tld| "#{domain}.#{tld}"}
          results += tlds.select{|tld| realwords.include? tld.downcase.gsub(".", '')}
        end
        if results.empty? 
          say "i couldnt come up with anything sry"
        else
          results.map! do |domain|
            domain.gsub!(".", '')
            if _check(domain) =~ /available/
              "*#{domain}*"
            else
              domain
            end
          end
          say "sexy domain hax for #{word}: #{results.join(", ")}"        
        end
      end
    end
  end
  
  def check data
    data.each do |domain|
       domain = domain.gsub(/[^\da-zA-Z\-]/, '').downcase

       if STANDARD_TLDS.include? domain[-3..-1]
         domain = domain[0..-4]
         word = ""         
       else      
         puts(result = _check(domain))  
         word = ", though"
         word = ", too" if result =~ /available/
       end
         
       STANDARD_TLDS.each do |postfix|
         result = _check(domain + postfix)
         if result =~ /available/ or word.empty?
           puts result.chomp("!") + word 
           word = ", too" unless word.empty?
         end           
       end

    end
  end
  
  if false #config[:nick] != "matz"
    def search_namespace data 
      power = data[0].to_i
      choices = []
      case data[1]
       when "mixed"
         choices += LETTERS + NUMBERS + ["-"]
       when "letters"
         choices += LETTERS
       when "numbers"
         choices += NUMBERS
       else
         puts "please say the combination length, then 'letters', 'numbers', or 'mixed', and the optionally the tlds to search" and return
      end
      
      postfixes = data[2..-1]
      postfixes = STANDARD_TLDS if postfixes.empty?
            
      total, count = 0, 0
      [false, true].each do |execute|
        choices.cartesian_power(power) do |c|
          postfixes.each do |postfix|
            if execute
              count += 1
              result = _check(c.join("") + postfix)
              (puts result and open("tld.search.#{data[0]}.#{data[1]}", 'a') {|f| f.puts result}) if result =~ /available/
              puts "ridin dirtay yeah! #{count} checks so far" if (count % 10000).zero?
            else
              total += 1
            end
          end       
        end
        puts "im in ur #{postfixes.join(", ")} namespacez"
        puts "findin ur #{total} #{power}-length combinations from #{choices.size} elementz" unless execute        
      end      
      puts "done finding ur namez"
    end
  end
  
  def tld data
    data.each do |tld|
      tld.gsub!('.', '')
      tld = interpolate(tld) unless TLDS[tld.to_sym]
      puts ".#{tld}: #{TLDS[tld.to_sym] or TLDS[(TLDS.keys.map{|s|s.to_s}.grep(/#{tld.to_sym}/).first.to_sym rescue nil)] or 'invalid'} (http://en.wikipedia.org/wiki/.#{tld.split(".").last})"
    end
  end
  
  private
  
  def _check domain
    if domain =~ /(#{TLDS.keys.join("|").gsub(".", "")})$/

      tld = TLDS[$1.to_sym] ? $1 : interpolate($1)
      domain = "#{domain[0..-($1.length + 1)]}.#{tld}" 
      #Debugger.start; debugger
      
      dig = if domain =~ /\.(#{STANDARD_TLDS.join("|")})$/ and domain.length < 7 or domain =~ /^\-|\-\./ or domain.length < 5
         "SERVFAIL"
      else
        whois_norecord = WHOIS_SPECIAL_NXDOMAINS[tld]
        if whois_norecord
          if `whois #{domain}` =~ /#{whois_norecord}/
            "NXDOMAIN"
          else
            "NOERROR"
          end
        else
          if ENV['HOME'] =~ /^\/Users/
            # os x
            `ssh allison dig @63.78.188.33 ns #{domain}`
          else
            # linux
            `dig ns #{domain}`
          end
        end
      end
      
      case dig
        when /NXDOMAIN/
          "#{domain} is available!"
        when /NOERROR/
         "#{domain} has already been registered..."
        when /SERVFAIL/
         "#{domain} is invalid or too short"
        else
         "#{domain} threw an error"
      end
    elsif domain =~ /(#{TLDS.keys.map{|k| k.to_s.split(".").last}.join("|")})$/
      "#{domain} is disabled (.#{$1} only allows tertiary registrations)"
    else
      "#{interpolate(domain)} is invalid"
    end
  end
  
  def interpolate s
    (s[0..-3] + "." + s[-2..-1]).gsub(/^\./, '') rescue s
  end
end


class Array
  def cartesian_power(n)
    iterations = size ** n
    iterations.times do |i|
      array = Array.new(n) do |j|
        k = i
        (n-j-1).times { k /= size }
        slice(k%size)
      end
      yield array
    end
  end
end
