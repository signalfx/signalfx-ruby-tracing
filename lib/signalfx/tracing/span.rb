require 'jaeger/span'

module SignalFx
  module Tracing
    module Span
      def record_exception(exception, record_error=true) 
        set_tag(:error, true) if record_error
        set_tag(:'sfx.error.kind', exception.class.to_s) 
        set_tag(:'sfx.error.message', exception.message)
        if not exception.backtrace.nil?
          set_tag(:'sfx.error.stack', exception.backtrace.join('\n'))
        end
      end
    end
  end
end

Jaeger::Span.class_eval { prepend SignalFx::Tracing::Span }
