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
          if Middleware.enabled
            request = Rack::Request.new env
            request_id = request.uuid
            Thread.current[:request_id] = request_id
          end
          @app.call(env)
        ensure
          if Middleware.enabled
            GeneralLog.general_log_with_request_id(request_id).writefile(request)
            GeneralLog.delete_general_log(request_id)
            Thread.current[:request_id] = nil
          end
        end
      end
    end
  end
end
