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

            begin
              require 'sinatra/instrumentation'
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
