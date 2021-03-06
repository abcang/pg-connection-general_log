require 'securerandom'

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
            request = Rack::Request.new(env)
            request_id = extract_request_id(env)
            Thread.current[:request_id] = request_id
          end
          @app.call(env)
        ensure
          if Middleware.enabled
            GeneralLog.general_log_with_request_id(request_id)&.writefile(request)
            GeneralLog.delete_general_log(request_id)
            Thread.current[:request_id] = nil
          end
        end

        def extract_request_id(env)
          env['action_dispatch.request_id'] || env['HTTP_X_REQUEST_ID'] || SecureRandom.hex(16)
        end
      end
    end
  end
end
