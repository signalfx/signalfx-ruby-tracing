require 'jaeger/span'

module SignalFx
  module Tracing
    module Span
      def set_error(error) 
        set_tag('error', true)
        log_kv(
          event: 'error',
          :'error.kind' => error.class.to_s,
          :'error.object' => error,
          message: error.message,
          stack: error.backtrace.join("\n")
        )
      end
    end
  end
end


Jaeger::Span.class_eval { include SignalFx::Tracing::Span }
