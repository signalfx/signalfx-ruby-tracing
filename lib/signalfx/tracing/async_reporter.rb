require 'jaeger/client/async_reporter'

# The Jaeger client's AsyncReporter creates a thread to handle sending spans on
# a flush interval. However, when a forking web server like Passenger forks a
# process that includes the tracer, the sender thread is lost.
#
# This checks for the thread's before pushing in a span to the buffer.
# If it doesn't exist, it creates a new thread.
#
# This should make its way into the client's AsyncReporter at some point.

module SignalFx
  module Tracing
    class AsyncReporter < Jaeger::Client::AsyncReporter
      def initialize(sender, flush_interval)
        @flush_interval = flush_interval
        super(sender)
      end

      def report(span)
        start_poll_thread if !@poll_thread
        super
      end

      def start_poll_thread
        @poll_thread = Thread.new do
          loop do
            flush
            sleep(@flush_interval)
          end
        end
      end
    end
  end
end
