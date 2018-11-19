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

            require 'rack/tracer'
          end
        end
      end
    end
  end
end
