require 'pg'
require 'benchmark'

require 'pg/connection/general_log/connection_ext'
require 'pg/connection/general_log/log'
require 'pg/connection/general_log/logger'
require 'pg/connection/general_log/middleware'
require 'pg/connection/general_log/version'

module PG
  class Connection
    module GeneralLog
      class << self
        def general_log
          Thread.current[:general_log] ||= {}
          Thread.current[:general_log][Thread.current[:request_id]] ||= Logger.new
        end

        def general_log_with_request_id(request_id)
          Thread.current[:general_log]&.fetch(request_id, nil)
        end

        def delete_general_log(request_id)
          Thread.current[:general_log]&.delete(request_id)
        end

        def prepend_module
          PG::Connection.send(:prepend, ConnectionExt)
        end
      end
    end
  end
end
