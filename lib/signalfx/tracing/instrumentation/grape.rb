require 'opentracing'

module SignalFx
  module Tracing
    module Instrumenter
      module Grape

        Register.add_lib :Grape, self

        class << self

          def instrument(opts = {})
            return if @instrumented

            begin
              require 'grape'
            rescue LoadError => error
              return
            end

            require 'grape/instrumentation'
            
            tracer = opts.fetch(:tracer, OpenTracing.global_tracer)
            parent_span = opts.fetch(:parent_span, nil)

            ::Grape::Instrumentation.instrument(tracer: tracer, parent_span: parent_span)

            @instrumented = true
          end
        end
      end
    end
  end
end
