require 'syslog/logger'

class Logger

  def self.log(message)
    log = Syslog::Logger.new 'trading_bot'

    puts message
    log.info message
  end

end
