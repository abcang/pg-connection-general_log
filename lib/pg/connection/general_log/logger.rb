require 'fileutils'
require 'date'

module PG
  class Connection
    module GeneralLog
      class Logger < Array
        def writefile(req)
          FileUtils.mkdir_p(Middleware.path)
          File.open(File.join(Middleware.path, "#{Date.today}.txt"), 'a') do |file|
            if req
              file.puts "REQUEST\t#{req.request_method}\t#{req.fullpath}\t#{self.length}"
            end

            file.puts self.map { |log| log.format(Middleware.backtrace) }.join("\n") + "\n\n"
          end
        end

        def push(sql, args, backtrace, time)
          super(Log.new(sql, args, backtrace, time))
        end
      end
    end
  end
end
