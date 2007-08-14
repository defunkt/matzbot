module MatzBot::Commands
  def version(data = nil)
    `svn info | grep Revision` =~ /(\d+)/
    say ["Version #{$1}" + ((`svn status | grep '^M'`.length > 0) ? ", with local changes" : "")]
  end
  
  def be_polite(data=nil)
    config[:only_when_addressed] = true
    say "Pardon me sir, I'll only speak when spoken to."
  end
  
  def be_noisy(data=nil)
    config[:only_when_addressed] = false
    say "WOO! Party!"
  end

protected
  def update(data)
    `svn up`
    say "Updating..."
    version
  end
end
