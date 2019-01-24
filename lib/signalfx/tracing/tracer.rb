
# The default jaeger tracer doesn't expose @reporter, and attr_accessor can't
# be added after the fact in a child class. So this just adds an old-fashioned
# setter for @reporter.

module SignalFx
  module Tracing
    class Tracer < ::Jaeger::Client::Tracer
      def set_reporter(reporter)
        @reporter = reporter
      end
    end
  end
end
