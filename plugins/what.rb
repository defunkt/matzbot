require 'open-uri'
require 'hpricot'

module MatzBot::Commands

  help_method :questions => [:who, :what, :where, :when, :why, :how]
  PREPOSITIONS = %w[so to from within on without with of in for then as who]
  INVALID_CLOSERS = %w[and the a an]
  
  def converse(data)
    begin
      verb = data.pop
      last = data
      current = inner_what([verb] + last).split(" ")
      while current
        say current.join(" ") + "..."
        last = current
        current = inner_what([verb] + last[-2..-1]).split(" ") rescue nil
        sleep(2)
      end
    rescue
      say "converse some phrase [are/is] "
    end 
  end
  
  def what(data)
    say inner_what(data) rescue nil
  end
  
  private
  def inner_what(data)
    return if data.length < 2
    
    verb = data.first
    data[-1] = data.last[0..-2] if data.last[-1..-1] == '?'
    
    return if verb !~ /is|am|are|was|were/ or data.length == 1

    pre_phrase = data[1..-1]
    post_phrase = []       
    if PREPOSITIONS.include? pre_phrase.last
      post_phrase.push pre_phrase.last
      pre_phrase = pre_phrase[0..-2]
    end
    pre_phrase = pre_phrase.join(" ")
    post_phrase = post_phrase.join(" ")
    
    mirrors = {'i' => ['you', {'am' => 'are', 'was' => 'were'}],
     'you' => ['i', {'are' => 'am', 'were' => 'was'}],
     'your' => ['my', {}],
     'my' => ['your', {}],
     'we' => ['you guys', {}],
     'our' => ['your', {}],
     'me' => ['you', {}]}
     
    phrase = [pre_phrase, verb, post_phrase].join(" ").strip.squeeze(" ")
     
    if phrase =~/(^| )(#{mirrors.keys.join("|")})( |$)/ 
      who = $2
      pre_phrase.gsub!(who, mirrors[who].first)
      post_phrase.gsub!(who, mirrors[who].first)
      verb = (mirrors[who].last[verb] or verb)
      phrase = [pre_phrase, verb, post_phrase].join(" ").strip.squeeze(" ")
    end   
    
    if phrase == 'i am'
      return "i am in ur base!!\nkillin ur d00ds!!!"
    end
    
    result = "NoResult"
    searches = (Hpricot(open("http://www.google.com/xhtml/search?q=%22#{phrase.gsub(" ", "+")}%22").read)/:div)
    searches = searches.select{|s| s.inner_html =~ /#{phrase}/im and s.inner_html !~ /Web results|in your extended network|listeners.* at.*last/m} 
    searches.collect! {|s| s.inner_html.gsub("\n", " ")[/<\/a>(.*)<span/, 1] }
    searches.compact!

    results = []    
    while !searches.empty? 
      result = searches[rand searches.length]
      searches.delete result
      
      result.gsub!(/<.*?>/, ' ')
      result.gsub!(/\&.{1,6}\;/, ' ')
      result.gsub!(/\s*-\s*/, ' ')
      result.gsub!(/[^\s\w\d\,-\;\:\.\'\?\!\?\(\)\]\[]/, '')
      result = result.squeeze(" ").strip.downcase
      result.gsub!(/.*(and|if|then|that|who|will|in|by|for|was)$/, " ")
      result = result.squeeze(" ").strip.downcase
      20.times do 
        result = result[/(#{phrase}.*)[\,|-|\;|\:|\.|\!|\?]+/, 1] || result
        result = result.squeeze(" ").strip.downcase
        result = result[/(#{phrase}.*?)\s(#{(PREPOSITIONS + INVALID_CLOSERS).join("|")})$/, 1] || result
        result = result.squeeze(" ").strip.downcase
        result = result[/(.*)\(/, 1] if result =~ /\(/ and result !~ /\)/
      end
      result.gsub!(/ ([st]) /, "'" + '\1 ')
      result += " to love" if result =~ / able$/
      result = result[/(.*)\s/, 1] if result.split(" ").last !~ /[aeiou]/
      results.push result unless !result or result !~/^#{phrase}/i or result =~/#{phrase}$/
    end
    
    if !results.empty?
      result = results.sort{|a,b| a.length <=> b.length}.last

#      tags = {'heart|love|desire' => '<3', 'flirt|sex|dirty|wink|mom' => ';)', 'happy|glad|wonderful|amazing|peace' => ':)', 'chris' => ':p'}
#      tags.each do |key, value|
#        if result =~ /#{key}/
#          result += "\n#{value}"
#          break
#        end
#      end
      result
      
    else
      if verb =~ /are|were/
        say "#{phrase} mysteries to man"
      else
        say "#{phrase} a mystery to man"
      end
      nil
    end
  end
  
  alias :who :what
  alias :where :what
  alias :when :what
  alias :why :what
  alias :how :what
 
end
