require 'jaeger/client/async_reporter'

# The Jaeger client's AsyncReporter creates a thread to handle sending spans on
# a flush interval. However, when a forking web server like Passenger forks a
# process that includes the tracer, the sender thread is lost.
#
# This leaves the responsibility with the application to hook into fork/restart
# events and restart this thread when it happens.

module SignalFx
  module Tracing
    class AsyncReporter < Jaeger::Client::AsyncReporter
      def initialize(sender, flush_interval)
        @flush_interval = flush_interval
        revive_poll_thread
        super(sender)
      end

      def revive_poll_thread
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
