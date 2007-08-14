require 'cgi'

module MatzBot::Commands
  TRY_URL = "http://tryruby.hobix.com/irb?cmd=" unless defined?(TRY_URL)

  if `hostname` =~ /darkstar/
    require 'timeout'
    def >>(data)
      begin
        Timeout.timeout(12) {
          say "=> " + instance_eval(data*" ").inspect
        }
      rescue TimeoutError
        say "=> [Timed out]"
      end
    end
    
    def reset_irb
      exec("kill -9 `cat /home/matz/matzbot.pid`")
    end
  else

    def >>(data)
      session[:tryruby] ||= wget("!INIT!IRB!")
  
      if cmd = data * ' '
        resp = wget(cmd, {'Cookie' => '_session_id=' + session[:tryruby]})
        if resp =~ /^Your session has been closed/
          session[:tryruby] = wget("!INIT!IRB!")
          resp  = wget(cmd, {'Cookie' => '_session_id=' + session[:tryruby]})
        end
        resp = resp.split("\n").select{|s| s !~ /^\s+from .+\:\d+(\:|$)/}.join("\n")
        puts resp.strip
      else
        puts "tryruby module: ?eval <code> => object"
      end
    end
  
    def reset_irb(data)
      session[:tryruby] = nil
      puts "irb reset!"
    end
  
  private
    def wget(url, hdrs = {})
      require 'open-uri'
      open(TRY_URL + CGI.escape(url), hdrs) do |f|
        f.read
      end
    end
  end
  
end
