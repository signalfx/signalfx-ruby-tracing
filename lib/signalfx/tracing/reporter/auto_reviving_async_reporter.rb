require 'jaeger/client/async_reporter'

# The Jaeger client's AsyncReporter creates a thread to handle sending spans on
# a flush interval. However, when a forking web server like Passenger forks a
# process that includes the tracer, the sender thread is lost.
#
# This checks for the thread's before pushing in a span to the buffer.
# If it doesn't exist, it creates a new thread.
#
# If you have control over hooking into fork events, signalfx/tracing/async_reporter
# and reviving it should be preferred.

module SignalFx
  module Tracing
    class AutoRevivingAsyncReporter < Jaeger::Client::AsyncReporter
      def initialize(sender, flush_interval)
        @flush_interval = flush_interval
        super(sender)
      end

      def report(span)
        revive_poll_thread if !@poll_thread
        super
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
