require "net/http"
require "json"

module ErrorInbox
  class Notifier
    HTTP_ERRORS = [
      Timeout::Error,
      Errno::EINVAL,
      Errno::ECONNRESET,
      EOFError,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      Errno::ECONNREFUSED,
      OpenSSL::SSL::SSLError
    ].freeze

    def initialize(options)
      @options = options.dup
    end

    def save(ex)
      if ErrorInbox.configuration.username && ErrorInbox.configuration.password
        response = begin
          http_request(prepare_body(ex))
        rescue *HTTP_ERRORS => ex
          ErrorInbox.configuration.logger.error("#{ex.class.name}: #{ex.message}")
          nil
        end

        case response
        when Net::HTTPCreated
          JSON.load(response.body)["id"]
        else
          ErrorInbox.configuration.logger.error(response.class.name)
          {}
        end
      else
        ErrorInbox.configuration.logger.error("Missing credentials configuration")
        {}
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

    def http_request(body)
      uri = URI("http://oops.errorinbox.com/")
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 5
      http.open_timeout = 4

      request = Net::HTTP::Post.new(uri.request_uri)
      request["Content-Type"] = "application/json"
      request.body = body
      request.basic_auth(ErrorInbox.configuration.username, ErrorInbox.configuration.password)
      http.request(request)
    end
  end
end
