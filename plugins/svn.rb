module MatzBot::Commands
  needs_gem 'hpricot' => ['poll']
  
  session[:repositories] ||= {}
  session[:last_poll] ||= Time.now
  
  filter :listen => :poll
  
  def add_repos(data)
    session[:repositories][data.first] = 0
    say "Okay I'll keep an eye on #{data.first}."
  end
  
  def show_repos(data)
    say session[:repositories].inspect
  end
  
  def clear_trac_tickets(data)
    session[:trac_tickets].clear
    stop_poll
    say "Clear.d."
  end

  def reset_repos(*data)
    session[:repositories].each { |k, v| session[:repositories][k] = 0 }
  end

  def remove_repos(data)
    return say("Gone.") if session[:repositories].delete(data.first)
    say "Which one?"
  end
  
  def poll(message)
    return unless (Time.now - session[:last_poll] > 15 rescue true)
    session[:last_poll] = Time.now    
    session[:repositories].each do |repo, last|
      (Hpricot(`svn log #{repo} -rHEAD:#{last} --limit 10 --xml`)/:logentry).reverse[1..-1].each do |ci|
        session[:repositories][repo] = rev = ci.attributes['revision'].to_i
        say "Commit #{rev} to #{repo.split("/").last} by #{(ci/:author).text}: #{(ci/:msg).text}"
      end rescue nil
    end
  end
end