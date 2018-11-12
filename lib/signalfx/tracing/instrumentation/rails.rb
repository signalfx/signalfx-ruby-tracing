module SignalFx
  module Tracing
    module Instrumenter
      module Rails

        Register.add_lib :Rails, self

        class << self

          def instrument(opts = {})
            # instrument supported versions
            return if !defined?(::Rails) or Gem::Version.new(::Rails::VERSION::STRING) < Gem::Version.new('3.2')

            require 'rails/tracer'
            require 'rack/tracer'

            if rack_tracer
              # add rack middlewares
              ::Rails.configuration.middleware.use(::Rack::Tracer)
              ::Rails.configuration.middleware.insert_after(::Rack::Tracer, ::Rails::Rack::Tracer)
            end

            ::Rails::Tracer.instrument(full_trace: true)
          end
        end
      end
    end
  end
end
