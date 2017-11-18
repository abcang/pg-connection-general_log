module PG
  class Connection
    module GeneralLog
      class Middleware
        class << self
          attr_accessor :enabled, :path, :backtrace
        end

        def initialize(app, options = {})
          @app = app
          Middleware.enabled = options[:enabled]
          Middleware.path = options[:path] || '/tmp/general_log'
          Middleware.backtrace = options[:backtrace] || false

          GeneralLog.prepend_module if Middleware.enabled
        end

        def call(env)
          GeneralLog.general_log.clear if Middleware.enabled
          @app.call(env)
        ensure
          if Middleware.enabled
            request = Rack::Request.new env
            puts request.path
            GeneralLog.general_log.writefile(request)
          end
        end
      end
    end
  end
end
