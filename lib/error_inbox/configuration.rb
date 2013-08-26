module ErrorInbox
  class Configuration
    attr_accessor :username, :password
    attr_writer :logger

    def logger
      @logger ||= begin
        require "logger"
        Logger.new(STDOUT)
      end
    end
  end
end
