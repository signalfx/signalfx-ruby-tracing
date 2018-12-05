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

            require 'mysql2/instrumentation'

            ::Mysql2::Instrumentation.instrument(tracer: SignalFx::Tracing::Instrumenter.tracer)
          end
        end
      end
    end
  end
end
