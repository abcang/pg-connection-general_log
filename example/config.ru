require_relative './test'

require 'pg/connection/general_log'

use PG::Connection::GeneralLog::Middleware, enabled: true, backtrace: true, path: '/tmp/general_log'
run Sinatra::Application
