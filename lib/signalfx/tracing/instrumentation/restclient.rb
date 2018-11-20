module SignalFx
  module Tracing
    module Instrumenter
      module RestClient

        Register.add_lib :RestClient, self

        class << self

          def instrument(opts = {})
            begin
              require 'restclient'
            rescue LoadError
              return
            end

            require 'restclient/instrumentation'
            
            ::RestClient::Instrumentation.instrument
          end
        end
      end
    end
  end
end
