module SignalFx
  module Tracing
    module Instrumenter
      module Rack

        Register.add_lib :Rack, self

        class << self

          def instrument(opts = {})
            begin
              require 'rack'
            rescue LoadError
              return
            end

            begin
              require 'rack/tracer'
            rescue LoadError => e
              puts e.message
              return
            end
          end
        end
      end
    end
  end
end
