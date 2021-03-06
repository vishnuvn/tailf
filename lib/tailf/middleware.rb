module Tailf
  class Middleware < Rails::Rack::Logger
    def initialize(app, opts = {})
      @app = app
      @opts = opts
      @opts[:silenced] ||= []
    end

    def call(env)
      puts @opts[:silenced].include?(env['PATH_INFO'])
      puts env['PATH_INFO']
      if env['X-SILENCE-LOGGER'] || @opts[:silenced].include?(env['PATH_INFO'])
        Rails.logger.silence do
          @app.call(env)
        end
      else
        @app.call(env)
      end
    end

  end
end


module Rails
  module Rack
    # Sets log tags, logs the request, calls the app, and flushes the logs.
    class Logger < ActiveSupport::LogSubscriber

      protected

      def call_app(request, env)
        bolcked_path = ["/assets/tailf/log.css", "/assets/tailf/application.css", "/assets/tailf/log.js", "/assets/tailf/application.js", "/application/log"]
        # Put some space between requests in development logs.
        if development? and !bolcked_path.include?(request.env["PATH_INFO"])
          logger.debug ''
          logger.debug ''
        end

        instrumenter = ActiveSupport::Notifications.instrumenter
        instrumenter.start 'request.action_dispatch', request: request
        logger.info started_request_message(request) unless bolcked_path.include?(request.env["PATH_INFO"])
        resp = @app.call(env)
        resp[2] = ::Rack::BodyProxy.new(resp[2]) { finish(request) }
        resp
      rescue
        finish(request)
        raise
      ensure
        ActiveSupport::LogSubscriber.flush_all!
      end
    end
  end
end

