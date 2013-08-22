module ErrorInbox
  class Rack
    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        response = @app.call(env)
      rescue Exception => raised
        ErrorInbox.notify(raised, env)
        raise raised
      end

      if framework_exception(env)
        ErrorInbox.notify(framework_exception(env), env)
      end

      response
    end

    protected

    def framework_exception(env)
      env["rack.exception"] || env["action_dispatch.exception"] || env["sinatra.error"]
    end
  end
end
