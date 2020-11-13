require 'jaeger/tracer'

# The default jaeger tracer doesn't expose @reporter, and attr_accessor can't
# be added after the fact in a child class. So this just adds an old-fashioned
# setter for @reporter.
# This also adds the set_error method that can be used to add an exception to
# the currently active span.

module SignalFx
  module Tracing
    class Tracer < ::Jaeger::Tracer
      def set_reporter(reporter)
        @reporter = reporter
      end

      def set_error(error)
        span = active_span
        span.set_error(error) if span 
      end
    end
  end
end
