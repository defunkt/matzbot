module MatzBot::Commands
  
  require 'open-uri'
  require 'rexml/document'
  
  GIT_URL = 'http://git.rubini.us/?p=code;a=atom'
  GIT_MAX = 3
  
  def update_git
    STDOUT.puts "updating git..."
    last_hash = session[:git_last_hash]
    data = open(GIT_URL).read
    
    doc = REXML::Document.new(data)
    
    i = 0
          
    REXML::XPath.each(doc, "//entry") do |entry|
      break if i == GIT_MAX
      i += 1
      
      title = REXML::XPath.first(entry, "./title")
      link =  REXML::XPath.first(entry, "./link")
      name =  REXML::XPath.first(entry, "./author/name")
      hash = link.attributes['href'].split("=").last
      
      break if hash == last_hash
      
      last_hash = hash if i == 1
      
      count = 0
      REXML::XPath.each(entry, "./content/div/ul/li") { |e| count += 1 }
      say "#{hash[0..7]} by #{name.text}, #{count} files changed"
      say "  #{title.text}"
    end
    
    STDOUT.puts "Last hash #{last_hash}"
    session[:git_last_hash] = last_hash
  end
  
  Signal.trap("USR2") do
    update_git
  end
end