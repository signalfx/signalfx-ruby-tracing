module SignalFx
  module Tracing
    module Instrumenter
      module Sinatra

        Register.add_lib :Sinatra, self

        class << self

          def instrument(opt = {})
            begin
              require 'sinatra'
            rescue LoadError
              return
            end

            require 'sinatra/instrumentation'
          end
        end
      end
    end
  end
end
