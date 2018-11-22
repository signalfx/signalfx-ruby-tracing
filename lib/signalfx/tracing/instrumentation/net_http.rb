module SignalFx
  module Tracing
    module Instrumenter
      module NetHttp

        Register.add_lib :NetHttp, self

        class << self

          def instrument(opts = {})
            require 'net/http/tracer'

            ::Net::Http::Tracer.instrument
          end
        end
      end
    end
  end
end
