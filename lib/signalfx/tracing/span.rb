require 'jaeger/span'

module SignalFx
  module Tracing
    module Span
      def record_exception(exception, record_error=true) 
        set_tag('error', true) if record_error
        log_kv(
          event: 'error',
          :'error.kind' => exception.class.to_s,
          :'error.object' => exception,
          message: exception.message,
          stack: exception.backtrace.join("\n")
        )
      end
    end
  end
end


Jaeger::Span.class_eval { include SignalFx::Tracing::Span }
