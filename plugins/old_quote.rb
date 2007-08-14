#module MatzBot::Commands
#  needs_gem 'mechanize' => :quote
#
#  DB_URI = "http://www.eskimo.com/~hottub/software/programming_quotes.html"
#  DB_CACHE = "/tmp/matzbot_serialized_quote_db"
#  
#  def quote(data)
#    unless File.exist? DB_CACHE
#      page = WWW::Mechanize.new.get(DB_URI).body
#      
#      @db = page.split(/\<img.*?\>/).collect { |s|
#        s.gsub(/\n/, " ").sub("<blockquote>", " - ").gsub(/\<.*?\>/, "").gsub(/\\222/, "'").strip.gsub("  ", " ")
#      }.select { |s| 
#        s !~ /^[\s\n]*$/ and s.length > 20
#      }.push("Der der I'm defunkt der der der. - defunkt")
#      
#      File.open(DB_CACHE, 'w') do |f|
#        f.puts YAML.dump(@db)
#      end
#    end
#
#    @db ||= YAML.load_file(DB_CACHE)
#    puts @db[rand(@db.length)]
#    
#  end
#  
#end
