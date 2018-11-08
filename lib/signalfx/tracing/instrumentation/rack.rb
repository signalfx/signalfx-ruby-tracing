module SignalFx
  module Tracing
    module Instrumenter
      module Rack

        Register.add_lib :Rack, self

        class << self

          def instrument(opts = {})
            require 'rack/tracer'
          end
        end
      end
    end
  end
end
