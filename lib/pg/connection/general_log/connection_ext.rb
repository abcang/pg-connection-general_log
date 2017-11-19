module PG
  class Connection
    module GeneralLog
      module ConnectionExt
        def initialize(*)
          @stmt_map = {}
          super
        end

        def exec(sql)
          ret = nil
          time = Benchmark.realtime do
            ret = super
          end
          GeneralLog.general_log.push(sql, [], caller_locations, time)
          ret
        end

        def exec_params(*args)
          sql, params = args
          ret = nil
          time = Benchmark.realtime do
            ret = super
          end
          GeneralLog.general_log.push(sql, params, caller_locations, time)
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
          GeneralLog.general_log.push(sql, params, caller_locations, time)
          ret
        end

        def async_exec(*args)
          sql, params = args
          ret = nil
          time = Benchmark.realtime do
            ret = super
          end
          GeneralLog.general_log.push(sql, params || [], caller_locations, time)
          ret
        end
      end
    end
  end
end
