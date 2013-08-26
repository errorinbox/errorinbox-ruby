require "error_inbox/version"
require "error_inbox/notifier"
require "error_inbox/configuration"

module ErrorInbox
  def self.notify(ex, env)
    notifier = Notifier.new(env)
    notifier.save(ex)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end
end
