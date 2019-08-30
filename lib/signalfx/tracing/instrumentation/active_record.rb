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

            begin
              require 'active_record/opentracing'
            rescue LoadError => e
              puts e.message
              return
            end
            ::ActiveRecord::OpenTracing.instrument if !@instrumented
            @instrumented = true
          end
        end
      end
    end
  end
end
