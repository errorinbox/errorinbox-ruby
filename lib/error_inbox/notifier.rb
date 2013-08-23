require "net/http"
require "json"

module ErrorInbox
  class Notifier
    def initialize(options)
      @options = options.dup
    end

    def save(ex)
      unless ErrorInbox.configuration.username && ErrorInbox.configuration.password
        raise MissingCredentialsError
      end

      uri = URI("http://oops.errorinbox.com/")
      req = Net::HTTP::Post.new(uri.path)
      req.basic_auth(ErrorInbox.configuration.username, ErrorInbox.configuration.password)
      req["Content-Type"] = "application/json"
      req.body = prepare_body(ex)
      res = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(req)
      end

      case res
      when Net::HTTPCreated
        JSON.load(res.body)["id"]
      when Net::HTTPForbidden
        raise InvalidCredentialsError
      else
        raise "Unknow error: #{res}"
      end
    end

    protected

    def prepare_body(ex)
      body = {
        :type => ex.class.name,
        :message => ex.message,
        :backtrace => ex.backtrace.join("\n"),
        :environmentName => ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development",
        :environment => {},
        :occurredAt => Time.now.xmlschema
      }

      rack_env = @options.delete(:rack_env)
      if rack_env.respond_to?(:each)
        require "rack"
        body[:request] = { :url => ::Rack::Request.new(rack_env).url }

        rack_env.each do |key, value|
          body[:environment][key] = value.to_s
        end

        if rack_session = rack_env["rack.session"]
          rack_session.each do |key, value|
            body[:session][key] = value.to_s
          end if rack_session.respond_to?(:each)
        end
      end

      @options.each do |key, value|
        value = value.to_s unless value.is_a?(Hash) || value.is_a?(Array)
        body[:environment][key] = value
      end

      JSON.dump(body)
    end
  end
end
