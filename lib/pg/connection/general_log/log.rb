module PG
  class Connection
    module GeneralLog
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
    end
  end
end
