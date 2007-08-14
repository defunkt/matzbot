require 'livejournal/login'
require 'livejournal/entry'
require 'hpricot'
require 'open-uri'

module MatzBot::Commands
  help_method :lj => [:blog, :quote]

  ACTIONS = %w(writes thinks types)

  MOODS = %w(distressed touched pessimistic hungry cheerful high amused disappointed cold sore grumpy mellow irate pleased tired ditzy energetic exanimate full crazy indifferent thirsty apathetic peaceful happy sympathetic nostalgic contemplative pensive loved listless rejuvenated flirty crushed angry horny bitchy sick exhausted irritated refreshed sleepy pissed off numb cynical thankful surprised embarrassed moody weird good frustrated cranky ecstatic morose naughty hopeful bored lazy jubilant complacent crappy satisfied envious dirty chipper giggly uncomfortable okay blah discontent blank recumbent jealous rejected melancholy content nauseated enraged excited hyper curious silly infuriated restless optimistic calm aggravated impressed thoughtful rushed sad intimidated stressed giddy nervous drained lethargic hot bouncy devious relaxed shocked relieved lonely scared quixotic confused worried mischievous annoyed groggy depressed guilty gloomy anxious drunk grateful)

  TALKS = %w(crap stuff things words chortles hawt lines good sweet only forever endlessly crazy)

  def blog(data)
    subject = data.join(" ")
    subject = MOODS[rand(MOODS.length)] if data.empty?
   
    count = 0
    begin
      body = open('http://lcamtuf.coredump.cx/b3/blog-re.shtml?said=' + CGI.escape(subject)).read[/<hr.*?>(.*)<hr/im, 1]
      body = body.gsub('<P>', "\n").gsub(/([^\n])\n([^\n])/, '\1 \2').gsub(/\n{1,3}/, " lnbrk ").downcase.split(" ")
      body[(i=rand(30))..(i+rand(8))] = [subject]
      body = body.join(" ")
      
      user = LiveJournal::User.new('matzbot', open("lj_password").read.chomp)
      (login = LiveJournal::Request::Login.new(user)).run
      entry = LiveJournal::Entry.new
      
      entry.subject = subject
      entry.subject = body[/lnbrk.*?\s.*?\s.*?\s(.*?)[^\w\s\']/, 1] if data.empty?
      
      entry.mood = languages(MOODS[rand(MOODS.length)] + " in koreanlish", true).downcase
      entry.moodid = rand(130)
      
      # and now a hack of great horribleness
      body = languages(body + (rand(3).zero? ? " in koreanlish" : ""), true)
      body = body.sub(/(.*?lnbrk.*?lnbrk.*?lnbrk)/, '\1' + image_for(subject) + 'lnbrk').gsub(/lnbrk/i, "\n\n").gsub(/[\[\]]/, "")
      entry.event = body
      
      entry.time = LiveJournal::coerce_gmt Time.now
      LiveJournal::Request::PostEvent.new(user, entry).run
      action "writes about #{subject} in his lj (http://matzbot.livejournal.com)" 
    rescue Object => boom
      count += 1
      retry if count < 8
      puts "dont wanna post right now sry"
#      puts boom.inspect
    end    
    
  end

  def quote data
    
    author = data.last
    talk = TALKS[rand(TALKS.size)]
    pronoun = "#{rand(5).zero? ? "S" : ""}HE"
    verb = "talks"
    
    if author =~ /matz/i
      author = "I" 
      pronoun = "I"
      verb.chop!
    end
    
    message = data[0..-2].join(" ")
    return if !message or message.empty?
    
    user = LiveJournal::User.new('matzbot', open("lj_password").read.chomp)
    (login = LiveJournal::Request::Login.new(user)).run
    entry = LiveJournal::Entry.new
        
    entry.subject = "#{author} #{verb} #{talk}".upcase
    entry.event = "<h2>#{pronoun} SAYZ:<BR><BR>&nbsp;&nbsp;&nbsp;#{message.upcase}</h2>"
    
    entry.time = LiveJournal::coerce_gmt Time.now
    LiveJournal::Request::PostEvent.new(user, entry).run
    
    action "quoteddd it k"
  end

  
  filter :listen => :blogurl_watcher
  
  private
  
  def blogurl_watcher(message)
    return unless message =~ /(^|\s)(http.*?)(\s|$)/
    
    url = $2
    url = url[0..-2] if url[url.length - 1] == 1
    
    user = LiveJournal::User.new('matzbot', open("lj_password").read.chomp)
    (login = LiveJournal::Request::Login.new(user)).run
    entry = LiveJournal::Entry.new
    
    title = (Hpricot(open(url))/:head/:title).innerHTML rescue nil
    title = url[/.*\/(.*)/, 1] if !title or title.empty?
   
    if url =~ /\.(png|gif|jpg|jpeg|bmp)$/i
      entry.subject = "picz lol"
    else
      entry.subject = title.downcase
    end
    
    entry.event = %Q(<a href="#{url}">#{title}</a>)
    
    entry.time = LiveJournal::coerce_gmt Time.now
    LiveJournal::Request::PostEvent.new(user, entry).run
  end
   
  def image_for subject
     begin
       url = "http://images.google.com/images?&q=#{CGI.escape(subject)}&nojs=1"
       src = (Hpricot(open(url))/:img)[4].attributes['src'][/(http.*)/, 1]
       raise unless src
       "<img width=\"350px\" style=\"padding-left: 35px; padding-right: 35px;\" src=\"#{src}\">"
     rescue Object => boom
       subject = subject.split(" ")[0..-2].join(" ")  
       retry unless subject.empty?
       ""
     end
  end

end