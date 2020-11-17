require 'jaeger/span'

module SignalFx
  module Tracing
    module Span
      def record_exception(exception, record_error=true) 
        set_tag('error', true) if record_error

        fields = {
          :event => 'error',
          :'error.kind' => exception.class.to_s,
          :'error.object' => exception,
          :message => exception.message,
        }

        if not exception.backtrace.nil?
          fields[:stack] = exception.backtrace.join('\n')
        end

        log_kv(**fields)
      end
    end
  end
end


Jaeger::Span.class_eval { include SignalFx::Tracing::Span }
