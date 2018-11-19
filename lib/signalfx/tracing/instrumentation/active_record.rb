module SignalFx
  module Tracing
    module Instrumenter
      module ActiveRecord

        Register.add_lib :ActiveRecord, self

        class << self

          def instrument(opts = {})
            # load ActiveRecord and ActiveSupport if present
            begin
              require 'active_support'
              require 'active_record'
            rescue LoadError
              return
            end

            require 'active_record/opentracing'
            ::ActiveRecord::OpenTracing.instrument
          end
        end
      end
    end
  end
end
