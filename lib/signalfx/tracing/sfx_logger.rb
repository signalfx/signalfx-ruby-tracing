require 'logger'

module SignalFx
  module Tracing
    module Logging

      LOG_LEVELS = {
          'unknown' => Logger::UNKNOWN,
          'fatal' => Logger::FATAL,
          'error' => Logger::ERROR,
          'warn' => Logger::WARN,
          'info' => Logger::INFO,
          'debug' => Logger::DEBUG
      }.freeze

      DEFAULT_LOG_PATH = '/var/log/signalfx/signalfx-ruby-tracing.log'
      DEFAULT_SHIFT_AGE = 5
      DEFAULT_SHIFT_SIZE = 1048576

      def self.create (log_path = ENV['SIGNALFX_LOG_PATH'] || DEFAULT_LOG_PATH,
                       sfx_shift_age = ENV['SIGNALFX_LOG_SHIFT_AGE'] || DEFAULT_SHIFT_AGE,
                       sfx_shift_size = ENV['SIGNALFX_LOG_SHIFT_SIZE'] || DEFAULT_SHIFT_SIZE)

        if log_path.upcase == 'STDOUT'
          @logger = Logger.new(STDOUT)
        elsif log_path.upcase == 'STDERR'
          self.create_stderr_logger()
        else
          begin
            @logger = Logger.new("#{log_path}", shift_age = sfx_shift_age, shift_size = sfx_shift_size)
          rescue Errno::EACCES, Errno::ENOENT => e
            self.create_stderr_logger(log_path, e)
          end
        end

        log_level = ENV['SIGNALFX_LOG_LEVEL'].downcase if ENV['SIGNALFX_LOG_LEVEL']
        @logger.level = LOG_LEVELS.fetch(log_level, Logger::WARN)
        @logger.datetime_format = '%Y-%m-%d %H:%M:%S'
        @logger.formatter = proc do | severity, datetime, progname, msg |
          "#{datetime}, #{severity}: #{msg} --- #{progname} \n"
        end
        @logger
      end

      def self.logger
        @logger ||= self.create
      end

      def self.create_stderr_logger(logpath=nil, error=nil)
        @logger = Logger.new(STDERR)
        if error
          @logger.error { "LOG FILE ACCESS ERROR:\n*** Failed to write to '#{logpath}': #{error.message}\n--> Please manually create the required resources and/or grant relevant access permissions to this user process.\n*** Defaulting to sending log statements to the standard error (STDERR) handle.\n"}
        end
      end
    end
  end
end
