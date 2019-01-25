module SignalFx
  module Tracing
    module Instrumenter
      module Sequel

        Register.add_lib :Sequel, self

        class << self

          def instrument(opts = {})
            begin
              require 'sequel'
            rescue LoadError
              return
            end

            require 'sequel/instrumentation'

            tracer = opts.fetch(:tracer, OpenTracing.global_tracer)

            ::Sequel::Instrumentation.instrument(tracer: tracer) if !@instrumented
            @instrumented = true
          end
        end
      end
    end
  end
end
