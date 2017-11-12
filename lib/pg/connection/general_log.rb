require 'pg'
require 'benchmark'

module PG
  class Connection
    module GeneralLog
      require 'pg/connection/general_log/version'

      class Log < Struct.new(:sql, :args, :backtrace, :time)
        def format(use_bt = false)
          ret = [
            'SQL',
            '(%07.2fms)' % (time * 1000),
            sql.gsub(/[\r\n]/, ' ').gsub(/ +/, ' ').strip,
            args.to_s
          ]
          ret << backtrace[0] if use_bt

          ret.join("\t")
        end
      end

      class Logger < Array
        def writefile(path: '/tmp/sql.log', req: nil, backtrace: false)
          File.open(path, 'a') do |file|
            if req
              file.puts "REQUEST\t#{req.request_method}\t#{req.path}\t#{self.length}"
            end

            file.puts self.map { |log| log.format(backtrace) }.join("\n")
            file.puts ''
          end
          self.clear
        end

        def push(sql, args, backtrace, time)
          super(Log.new(sql, args, backtrace, time))
        end
      end

      attr_accessor :general_log

      def initialize(opts = {})
        @general_log = Logger.new
        @stmt_map = {}
        super
      end

      def exec(sql)
        ret = nil
        time = Benchmark.realtime do
          ret = super
        end
        @general_log.push(sql, [], caller_locations, time)
        ret
      end

      def exec_params(*args)
        sql, params = args
        ret = nil
        time = Benchmark.realtime do
          ret = super
        end
        @general_log.push(sql, params, caller_locations, time)
        ret
      end

      def prepare(*args)
        stmt_name, sql = args
        @stmt_map[stmt_name] = sql
        super
      end

      def exec_prepared(*args)
        stmt_name, params = args
        sql = @stmt_map[stmt_name]

        ret = nil
        time = Benchmark.realtime do
          ret = super
        end
        @general_log.push(sql, params, caller_locations, time)
        ret
      end
    end

    prepend GeneralLog
  end
end
