module SignalFx
  module Tracing
    module Instrumenter
      module MongoDB

        Register.add_lib :MongoDB, self

        class << self

          def instrument(opts = {})
            begin
              require 'mongo'
            rescue LoadError
              return
            end

            begin
              require 'mongodb/instrumentation'
            rescue LoadError => e
              puts e.message
              return
            end

            ::MongoDB::Instrumentation.instrument
          end
        end
      end
    end
  end
end
