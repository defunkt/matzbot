require 'open-uri'
require 'uri'
require 'net/http'

module MatzBot::Commands
  filter :listen => :languages
  filter :say => :language_talk
  
  def speak(data)
    session[:language] = data.first.downcase
    action "becomes a #{session[:language].capitalize} bot."
  end
  
  def languages(message, is_say_filter = false)
    url_google = 'http://www.google.com/translate_t'
    url_dialect = 'http://www.rinkworks.com/dialect/'
    
    if message.is_a? Array
      langs = []
      open(url_google).read.split("</option><option value=\"").each do |lang|
        if lang =~ /English to (.*)/
          langs.push $1.gsub(/\&.*?;/, ' ').gsub(/BETA/, '').strip
        end
      end
      open(url_dialect).read[/<select name="dialect">\n(.*?)<\/select>/m, 1].split("\n").each do |lang|
        if lang =~ />\s(.*)$/
          langs.push $1
        end
      end
      langs.push "Snoop"
      
      say "Available languages: #{langs.uniq.join(", ")}"
    else
      lang_pairs = []
      begin while message.strip =~ /(.*)\s(in|to|from)\s(\w{3,})$/ 
        message = $1
        direction = $2
        lang = $3
        if lang =~ /(.*)lish$/
          real_lang = $1
          lang_pairs.unshift ['from', real_lang]
          lang_pairs.unshift ['in', real_lang]
        else
          lang_pairs.unshift [direction, lang]
        end
      end
      
#      say "#{lang_pairs.length} pairs"
      translated = false
      
      lang_pairs.each do |direction, lang|
#        say "#{message} :: #{direction} :: #{lang}"
          
          # get the google language we're interested in
          if direction =~ /in|to/
            phrase = "English to #{lang}"
          elsif direction =~ /from/
            phrase = "#{lang} to English"
          end
          lang_code = open(url_google).read.split("</option><option value=\"").grep(/#{phrase}/i)
          
          # translate
          if !lang_code.empty?
            message = open(URI.escape(url_google + "?text=#{message}&langpair=#{lang_code.first[0..4]}")).read[/result_box.*?\>(.*?)<\/div/, 1].gsub(/\&\#\d\d;/, '')
            translated = true
            
          elsif direction =~ /in|to/
            # look for dialectizer languages
            lang_code = open(url_dialect).read[/<select name="dialect">\n(.*?)<\/select>/m, 1].split("\n").grep(/#{lang}/i)
            
            if !lang_code.empty?
              url_dialect_post = 'http://www.rinkworks.com/dialect/dialectt.cgi'
              response, content = Net::HTTP.post_form(URI.parse(url_dialect_post), 
                 {'dialect' => lang_code.first[/\"(.*?)\"/, 1], 'text' => message})
              # this markup is fucked
              if parsed = content[/Your Text, Dialectized.*?<p>(.*?)<\/td>/m, 1]
                message = parsed
                translated = true
              end
            elsif lang =~ /snoop/i
              url_snoop = 'http://www.gizoogle.com/index.php?translate=true&transtext='
              message = open(url_snoop + URI.escape(message)).read[/.*?Sponsored Links.*?width=\"500\".*?br>(.*?)\s+<\/TD>/m, 1]
              translated = true
            end
          end
       end
     
       {'lt' => '<', 'gt' => '>', 'quot' => "'"}.each do |k, v|
         message.gsub!("&#{k};", v)
       end           
       message.squeeze!(" ")
     
       unless lang_pairs.empty? or !translated or is_say_filter
          say message
           
          if lang_pairs.last[1] == "spanish" and rand(5) == 0
            action "puts on a sombrero"
            say "cha cha cha"
          end
       end
     end

     message if is_say_filter
      
   end
  end

  private  
  def language_talk(message)
    session[:language] ||= "english"
    return message unless session[:language] != "english"
    languages(message + " in #{session[:language]}", true)
  end
  
end
