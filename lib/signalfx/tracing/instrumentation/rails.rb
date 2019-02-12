module SignalFx
  module Tracing
    module Instrumenter
      module Rails

        Register.add_lib :Rails, self

        class << self

          def instrument(opts = {})
            return if @instrumented

            # instrument supported versions
            return if !defined?(::Rails) or Gem::Version.new(::Rails::VERSION::STRING) < Gem::Version.new('4.2')

            begin
              require 'activesupport'
            rescue Error => e
              return
            end

            require 'rails/instrumentation'
            require 'rack/tracer'

            if opts.fetch(:rack_tracer, true)
              # add rack middlewares
              ::Rails.configuration.middleware.use(::Rack::Tracer)
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
