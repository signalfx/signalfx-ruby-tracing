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
            patch_middleware if !opts.fetch(:disable_patching, false)

            @instrumented = true
          end

          def patch_middleware
            require 'rack/tracer'

            ::Grape::API.class_eval do
              if Gem::Version.new(::Grape::VERSION) >= Gem::Version.new('1.2.0')
                singleton_class.send(:alias_method, :initial_setup_original, :initial_setup)

                def self.initial_setup(base_instance_parent)
                  initial_setup_original(base_instance_parent)
                  base_instance_parent.insert(0, ::Rack::Tracer) if !base_instance_parent.middleware.any? { |m| m[2].to_s == 'Rack::Tracer'}
                end
              else
                singleton_class.send(:alias_method, :inherited_original, :initial_setup)

                def self.inherited(api)
                  inherited_original(api)
                  api.use(::Rack::Tracer) if !api.middleware.any? { |m| m[1].to_s == 'Rack::Tracer' }
                end
              end
            end # class_eval
          end
        end
      end
    end
  end
end
