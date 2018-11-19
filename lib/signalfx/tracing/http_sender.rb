require 'jaeger/client/http_sender'

module SignalFx
  module Tracing
    class HttpSenderWithFlag < Jaeger::Client::HttpSender
      def send_spans(spans)
        Thread.current.thread_variable_set(:http_sender_thread, true)

        super
      ensure
        Thread.current.thread_variable_set(:http_sender_thread, nil)
      end
    end
  end
end
