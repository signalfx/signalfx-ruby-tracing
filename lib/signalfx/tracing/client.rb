require 'jaeger/client/tracer'

module SignalFx
  module Tracing
    class Client < Jaeger::Client::Tracer
      def set_reporter(reporter)
        @reporter = reporter
      end
    end
  end
end
