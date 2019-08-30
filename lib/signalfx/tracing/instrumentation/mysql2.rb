module SignalFx
  module Tracing
    module Instrumenter
      module Mysql2

        Register.add_lib :Mysql2, self

        class << self

          def instrument(opts = {})
            begin
              require 'mysql2'
            rescue LoadError
              return
            end

            begin
              require 'mysql2/instrumentation'
            rescue LoadError => e
              puts e.message
              return
            end

            ::Mysql2::Instrumentation.instrument(tracer: SignalFx::Tracing::Instrumenter.tracer) if !@instrumented
            @instrumented = true
          end
        end
      end
    end
  end
end
