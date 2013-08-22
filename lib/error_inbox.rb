require "error_inbox/version"
require "error_inbox/notifier"
require "error_inbox/configuration"

module ErrorInbox
  class MissingCredentialsError < StandardError; end
  class InvalidCredentialsError < StandardError; end

  def self.notify(ex, env)
    notifier = Notifier.new(env)
    notifier.save(ex)
  end

  def self.configuration
    @configuration ||= Configuration.new
    yield @configuration if block_given?
    @configuration
  end
end
