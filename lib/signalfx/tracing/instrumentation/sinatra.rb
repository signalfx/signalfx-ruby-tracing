module SignalFx
  module Tracing
    module Instrumenter
      module Sinatra

        Register.add_lib :Sinatra, self

        class << self

          def instrument
            require 'sinatra/tracer'
          end
        end
      end
    end
  end
end
