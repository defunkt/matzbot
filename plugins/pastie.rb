require 'net/http'
require 'hpricot'
require 'open-uri'
#require 'mechanize'

module MatzBot::Commands

#  def pastie(data)    
#    pastie = "pastie.caboo.se"
#    url = "http://#{pastie}/paste"
#    search_url = "http://#{pastie}/search?q="
#    agent = WWW::Mechanize.new
#    form = agent.get(url).forms[1]
#    form['paste[body]'] = "#{config[:nick]} says hello"
#    posted = agent.submit(form)
#    edit_url = posted.uri.to_s + "/edit"
#    session_id = agent.cookie_jar.jar[pastie]['_session_id']
#
#    pm "Here's your pastie url. When you complete your paste, the link will be announced in #{config[:channel]}."
#    # depends on web.rb plugin
#    pm get_tinyurl(search_url + uri_escape(compose_js(session_id, edit_url)))
#
#    pastie_listen(posted.uri.to_s, pastie)
#  end

  def run_pastie(data)
    url = data.first
    url = "http://p.caboo.se/#{url}" if url.to_i.to_s == url
    puts "Evalin' #{url.split('/').last}..."
    url = (Hpricot(open(url).read)/:a/".utility").select{|e| e.innerHTML =~ /view/i}.first.attributes['href']
    open(url).read.split("\n").each { |line| send(:>>, line.split(' ')) }
  rescue
    puts "Pastie problem, ho."
  end

#private
#  def pastie_listen(uri, pastie)
#    r = Net::HTTP.new(pastie)
#    unpasted = r.get(uri).body
#    21.times do 
#      sleep(5)
#      if unpasted != (pasted = r.get(uri).body)
#        puts "#{MatzBot::Client.last_nick} has pasted a paste at: #{uri}" and return
#      end
#    end
#    pm "You didn't paste in time. You had 2 minutes to paste your paste; now I must say goodbye."    
#  end
#
#  def uri_escape(string)
#    string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
#      '%' + $1.unpack('H2' * $1.size).join('%').upcase
#    end.tr(' ', '+')
#  end
#
#  def compose_js(session_id = nil, edit_url = nil)
#   %[<script>document.cookie='#{session_id.to_s}; expires=; path=/';window.location='#{edit_url}';</script>]
#  end
end
