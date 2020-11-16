require 'test/unit'
require_relative '../lib/signalfx/tracing'

module SignalFx 
  class CustomTracerTest 

    class TraceTest < Test::Unit::TestCase
      require 'test/unit'

      Instrumenter = SignalFx::Tracing::Instrumenter

      def test_no_active_span
        Instrumenter.instance_variable_set(:@ingest_url, "")
        tracer = Instrumenter.new_tracer(service_name: "test-service") 
        span = tracer.start_span("test span")
        assert_equal span.logs.length, 0 
        assert_equal span.tags.length, 2 

        begin
          raise "test error 1"
        rescue StandardError => err
          tracer.set_error(err)
        end

        assert_equal span.logs.length, 0 
        assert_equal span.tags.length, 2 
      end
          
      def test_active_span
        Instrumenter.instance_variable_set(:@ingest_url, "")
        tracer = Instrumenter.new_tracer(service_name: "test-service")
        span = tracer.start_active_span("test span").span
        assert_equal span.logs.length, 0 
        assert_equal span.tags.length, 2 

        begin
          raise RuntimeError, "test error 2"
        rescue RuntimeError => err
          tracer.set_error(err)
        end

        assert_equal span.logs.length, 1 
        assert_equal span.tags.length, 3 
        err_tag = span.tags.last
        assert_equal err_tag.key, "error"

        err_log = span.logs.last
        kv_event = err_log.fields[0]
        kv_kind = err_log.fields[1]
        kv_object = err_log.fields[2]
        kv_message = err_log.fields[3]
        kv_stack = err_log.fields[4]

        assert_equal kv_event.key, "event"
        assert_equal kv_event.vStr, "error"
        assert_equal kv_kind.key, "error.kind"
        assert_equal kv_kind.vStr, "RuntimeError"
        assert_equal kv_object.key, "error.object"
        assert_equal kv_object.vStr, "test error 2"
        assert_equal kv_message.key, "message"
        assert_equal kv_message.vStr, "test error 2"
        assert kv_stack.vStr.length > 50
        assert kv_stack.vStr.include? 'custom_tracer_test.rb'
      end
    end
  end
end