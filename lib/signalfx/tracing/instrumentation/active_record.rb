module SignalFx
  module Tracing
    module Instrumenter
      module ActiveRecord

        Register.add_lib :ActiveRecord, self

        class << self

          def instrument
            require 'active_record/opentracing'
            ::ActiveRecord::OpenTracing.instrument
          end
        end
      end
    end
  end
end
