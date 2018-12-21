module SignalFx
  module Tracing
    module Instrumenter
      module Redis

        Register.add_lib :Redis, self

        class << self
          def instrument(opts = {})
            begin
              require 'redis'
            rescue LoadError => e
              return
            end

            require 'redis/instrumentation'

            tracer = opts.fetch(:tracer, OpenTracing.global_tracer)
            ::Redis::Instrumentation.instrument(tracer: tracer)
          end
        end
      end
    end
  end
end
