module SignalFx
  module Tracing
    module Instrumenter
      module Sinatra

        Register.add_lib :Sinatra, self

        class << self

          def instrument(opt = {})
            return if !defined?(::Sinatra)

            require 'sinatra/tracer'
          end
        end
      end
    end
  end
end
