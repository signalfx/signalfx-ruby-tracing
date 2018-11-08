module SignalFx
  module Tracing
    module Instrumenter
      module Sinatra

        Register.add_lib :Sinatra, self

        class << self

          def instrument(opt = {})
            require 'sinatra/tracer'
          end
        end
      end
    end
  end
end
