require 'net/http'
require 'open-uri'
require 'hpricot'

module MatzBot::Commands

  def sing(data)
    query = data.join(" ")
    # get most popular songs
    if query.length == 0
      popular = Hpricot(open('http://chart.lyricsfreak.com/lyrics.html').read)
      sing_song((links = (popular/"#lyric"/:a))[rand(links.length)].attributes['href'])
    else    
      begin
        google = Net::HTTP.new('www.google.com')
        url = google.get("/search?q=#{query.gsub(" ", "+")}+site%3Awww.lyricsfreak.com&btnI")['Location']
        search = Hpricot(open(url).read)
        unless (search/"#lyric").inner_html == ""
          url = (links = (search/"#lyric"/:a))[rand(links.length)].attributes['href']
        end
        sing_song(url) 
      rescue Exception
        say("couldnt find it " + ":( " * rand(3))
      end
    end
  end

  private 
  def sing_song(song_url)
    song = (Hpricot(open(song_url).read))
    lines = (song/"#content").innerHTML.gsub("\n", '').split("<br />").map{|s| s.strip.squeeze(" ")}.select{|s| s.length > 0}[0..rand(3)+5]
    raise RuntimeError if lines.join(" ") =~ /wikipedia/i
    title = (song/:title).first.innerHTML.gsub(/lyrics/i, '').sub('|', '-').strip.squeeze(" ") rescue nil
    if title
      action ["clears his throat", "sings", "coughs"][rand(3)] and sleep(1) if rand(4) == 0
      lines.each do |line|
        next if !line or line.length == 0 or line =~ /\&|\[|\]|\)|\(|chorus|verse/i
        [',', '.', '!', '?', '-', ';', ':'].map{|p| line.chomp! p}
        say "#{line}...".downcase.gsub(/\&.{1,4}\;/, '')
        sleep rand(2)
      end
      sleep(2)
      say "    - #{title}".downcase.gsub(/\&.{1,4}\;/, '')
    else 
      say "no such song, sillyhead"
    end
  end  
end