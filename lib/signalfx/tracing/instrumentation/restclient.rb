module SignalFx
  module Tracing
    module Instrumenter
      module RestClient

        Register.add_lib :RestClient, self

        class << self

          def instrument(opts = {})
            require 'restclient/instrumentation'
            
            ::RestClient::Instrumentation.instrument
          end
        end
      end
    end
  end
end
