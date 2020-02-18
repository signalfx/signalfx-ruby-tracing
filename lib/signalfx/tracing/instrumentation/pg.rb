require_relative '../sfx_logger'

module SignalFx
  module Tracing
    module Instrumenter
      module PG

        @logger = Logging.logger
        @logger.debug('SFx pg-instrumentation') { "Initializing instrumentation ..." }

        Register.add_lib :PG, self

        class << self

          def instrument(opts = {})
            return if @instrumented

            # check for required gems
            begin
              require 'pg'
            rescue LoadError
              return
            end

            begin
              require 'pg/instrumentation'
            rescue LoadError => e
              @logger.error { e.message }
              return
            end

            tracer = opts.fetch(:tracer, OpenTracing.global_tracer)

            ::PG::Instrumentation.instrument(tracer: tracer) if !@instrumented
            @instrumented = true
          end
        end
      end
    end
  end
end
