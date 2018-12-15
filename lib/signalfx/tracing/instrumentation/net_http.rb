module SignalFx
  module Tracing
    module Instrumenter
      module NetHttp

        Register.add_lib :NetHttp, self

        class << self

          def instrument(opts = {})
            require 'net/http/instrumentation'

            ignore_request = lambda { Thread.current.thread_variable_get(:http_sender_thread) }
            ::Net::Http::Instrumentation.instrument(ignore_request: ignore_request)
          end
        end
      end
    end
  end
end
