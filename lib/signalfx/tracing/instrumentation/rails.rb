module SignalFx
  module Tracing
    module Instrumenter
      module Rails

        Register.add_lib :Rails, self

        class << self

          def instrument(opts = {})
            return if @instrumented

            # check for required gems
            begin
              require 'active_support'
              require 'rails'
            rescue LoadError
              return
            end

            begin
              require 'rails/instrumentation'
            rescue LoadError => e
              puts e.message
              return
            end

            if opts.fetch(:rack_tracer, true)
              begin
                # add rack middlewares
                require 'rack/tracer'
                ::Rails.configuration.middleware.insert(0, ::Rack::Tracer)
              rescue LoadError => e
                puts e.message
              end
            end

            exclude_events = opts.fetch(:exclude_events, [])
            tracer = opts.fetch(:tracer, OpenTracing.global_tracer)

            ::Rails::Instrumentation.instrument(tracer: tracer, exclude_events: exclude_events)

            @instrumented = true
          end
        end
      end
    end
  end
end
