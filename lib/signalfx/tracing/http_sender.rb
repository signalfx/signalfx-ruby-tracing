require 'jaeger/client/http_sender'

# This child class of HttpSender exists to allow Net::HTTP instrumentation to
# ignore requests made by the tracer. The tracer uses the Thrift HTTP Transport,
# which uses Net::HTTP internally, to send spans to the collector.
#
# The sender spins in a separate thread to send spans. The overridden
# HttpSender#send_spans sets a thread variable, :http_sender_thread, which is
# checked with a block passed to the Net::HTTP instrumentation.

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
