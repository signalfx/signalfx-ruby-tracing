module SignalFx
  module Tracing
    module Instrumenter
      module RestClient

        Register.add_lib :RestClient, self

        class << self

          def instrument(opts = {})
            begin
              require 'restclient'
            rescue LoadError
              return
            end

            begin
              require 'restclient/instrumentation'
            rescue LoadError => e
              puts e.message
              return
            end
            
            tracer = opts.fetch(:tracer, OpenTracing.global_tracer)
            propagate = opts.fetch(:propagate, false)
            ::RestClient::Instrumentation.instrument(tracer: tracer, propagate: propagate) if !@instrumented
            @instrumented = true
          end
        end
      end
    end
  end
end
