module ErrorInbox
  class Configuration
    attr_accessor :username, :password
    attr_writer :logger

    def ignore_if(&block)
      ignores << block
    end

    def ignores
      @ignores ||= []
    end

    def logger
      @logger ||= begin
        require "logger"
        Logger.new(STDOUT)
      end
    end
  end
end
