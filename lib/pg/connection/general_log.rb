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
          Thread.current[:general_log] ||= Logger.new
        end

        def prepend_module
          PG::Connection.send(:prepend, ConnectionExt)
        end
      end
    end
  end
end
