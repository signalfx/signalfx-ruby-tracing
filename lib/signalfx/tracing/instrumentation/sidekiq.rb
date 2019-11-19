module SignalFx
  module Tracing
    module Instrumenter
      module Sidekiq

        Register.add_lib :Sidekiq, self

        class << self
          def instrument(opts = {})
            return if @instrumented
            begin
              require 'sidekiq'
            rescue LoadError
              return
            end

            begin
              require 'sidekiq/tracer'
            rescue LoadError => e
              puts e.message
              return
            end

            ::Sidekiq::Tracer.instrument(
              tracer: opts.fetch(:tracer, OpenTracing.global_tracer),
              opts: { propagate_context: opts.fetch(:propagate, true) }
            )
            @instrumented = true
          end
        end
      end
    end
  end
end

