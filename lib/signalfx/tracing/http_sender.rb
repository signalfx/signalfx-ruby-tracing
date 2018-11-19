require 'jaeger/client/http_sender'

module SignalFx
  module Tracing
    class HttpSenderWithFlag < Jaeger::Client::HttpSender
      def initialize(url: nil, headers: {}, encoder: nil, logger: nil, call_before: nil, call_after: nil)
        @call_before = call_before
        @call_after = call_after
        super(url: url, headers: headers, encoder: encoder, logger: logger)
      end

      def send_spans(spans)
        @call_before.call if @call_before

        super

        @call_after.call if @call_after
      end
    end
  end
end
