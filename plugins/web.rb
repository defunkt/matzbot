require 'net/http'
require 'open-uri'
require 'rfuzz/session'
require 'cgi'

module MatzBot::Commands
  needs_gem 'hpricot' => [ :del, :rubyurl, :get_rubyurl, :burner ]

  def google(data, title = true)
    return if data.empty?
    google = Net::HTTP.new('www.google.com')
    lucky = google.get("/search?q=#{data * '+'}&btnI")['Location']
    puts $1.gsub(/\n|\r/,' ').strip if open(lucky).read =~ /<title>(.*?)<\/title>/mi if title
    puts lucky
    blogurl_watcher lucky
  rescue
    puts "Uh, nothing."
  end

  def wiki(data)
    google(data.unshift("wikipedia+site:en.wikipedia.org"), false)
  end

  def alexa(data)
    return if data.empty?
    alexa = Net::HTTP.new('www.alexa.com')

    if alexa.get("/data/details/traffic_details?url=#{data}").body =~ /<span class="descBold">(.*?)<\/span>/
      content = $1.dup
      rank = content.scan(/>(\d+)</)
      say "Alexa guesses #{data}'s rank to be #{rank}."
    else
      say "No dice, dude."
    end
  end

  def technorati(data)
    return if data.empty? 
    technorati = Net::HTTP.new('www.technorati.com')

    if (body = technorati.get("/search/#{data}").body) =~ /Rank: ([0-9,]+).*?\(([0-9,]+) links from ([0-9,]+) blogs\)/
      string = "Looks like #{data} has a rank of #$1."
      string << " (That's #$2 links from #$3 blawgs.)" if $2 
      say string
    elsif body =~ /([0-9,]+) links to this URL/
      say "No ranking, but #{data} is linked to #$1 times."
    else
      say "No ranking."
    end
  end

  def del(data)
    return if data.empty?
    data = data.to_s
    delicious = Net::HTTP.new('del.icio.us')

    if data =~ /^http:/
      require 'digest/md5'
      url = Digest::MD5.hexdigest(data)
      if delicious.get("/url/#{url}").body =~ /saved by ([0-9,]+) people/
        say "#{data} has been saved by #$1 people"
      else
        say "No one's saved that url."
      end
    else
      doc = Hpricot(delicious.get("/#{data}").body)
      link = (doc/:h4).first/:a
      say link.first['href']
      say link.innerHTML
    end
  rescue
    say "I... I don't think so."
  end

  def worth(data)
    return if data.empty?
    url = name = data.first
    url += '.com' unless url['.']
    res = Net::HTTP.post_form(URI.parse('http://www.business-opportunities.biz/projects/how-much-is-your-blog-worth/'), { 'url' => url })
    if res.body =~ /is worth ([0-9,.$]+)/
      price = $1
      price = price == '$0.00' ? 'less' : " #{price}"
      say "#{name} is worth#{price}" 
    end
  rescue 
    say "No go, broke kid."
  end
  
  #filter :listen => :rubyurl_watcher
  
#  def rubyurl_watcher(message)
#    return if message =~ /run_pastie/
#    return unless message =~ /(^|\s)(http.*?)(\s|$)/
#
#    url = $2
#    url = url[0..-2] if url[url.length - 1] == 1
#
#    if url.length > "http://rubyurl.com/xxxxx".length
#      response = get_rubyurl url
#      action "shortens that to #{response}" if response
#    end
#  end
#
#  def rubyurl(data)
#    say "Here it is! #{get_rubyurl(data.first)}"
#  rescue
#    say "Rubyurl barfed on that one."
#    action "gets a bucket and some lysol"
#  end
  
  def burner(data)
    return if data.empty?
    url = "http://api.feedburner.com/awareness/1.0/GetFeedData?uri=#{data.first}"
    doc = Hpricot.parse open(url)
    entry = (doc/:entry).first
    circ = entry.attributes['circulation']
    hits = entry.attributes['hits']
    puts "Circulation: #{circ} | Hits in the Last 24 hours: #{hits}"
  rescue
    puts "Feed error! Make sure that the url is correct and that the API is turned on for it"
  end

private
  def get_rubyurl(url)
    return if url.empty?
    include RFuzz
    
    agent = "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.0.4) Firefox/1.5.0.4" 
    target = HttpClient.new("rubyurl.com", 80)
    res = target.get("/rubyurl/remote", 
       :head => {"User-Agent" => agent}, 
       :query => {"website_url" => url}) rescue nil
    res['LOCATION'].sub('/rubyurl/show', '') rescue nil
  end

end
