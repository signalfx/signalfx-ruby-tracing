require 'test/unit'
require_relative '../lib/signalfx/tracing'

module SignalFx 
  class CustomTracerTest 

    class CustomError < StandardError
    end

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
          tracer.record_exception(err)
        end

        assert_equal span.logs.length, 0 
        assert_equal span.tags.length, 2 
      end
          
      def test_record_exception
        Instrumenter.instance_variable_set(:@ingest_url, "")
        tracer = Instrumenter.new_tracer(service_name: "test-service")
        span = tracer.start_active_span("test span").span
        assert_equal span.tags.length, 2 

        begin
          raise RuntimeError, "test error 2"
        rescue RuntimeError => err
          tracer.record_exception(err)
        end

        assert_equal span.tags.length, 6 
        err_tag, kind_tag, msg_tag, stack_tag = span.tags[2..]
        assert_equal err_tag.key, "error"
        assert_equal err_tag.vBool, true
        assert_equal kind_tag.key, "sfx.error.kind"
        assert_equal kind_tag.vStr, "RuntimeError"
        assert_equal msg_tag.key, "sfx.error.message"
        assert_equal msg_tag.vStr, "test error 2"
        assert stack_tag.key, 'sfx.error.stack'
        assert stack_tag.vStr.length > 50
        assert stack_tag.vStr.include? 'test/errors_test.rb'
      end

      def test_record_exception_without_error_tag
        Instrumenter.instance_variable_set(:@ingest_url, "")
        tracer = Instrumenter.new_tracer(service_name: "test-service")
        span = tracer.start_active_span("test span").span
        assert_equal span.tags.length, 2 

        begin
          raise RuntimeError, "test error 2"
        rescue RuntimeError => err
          tracer.record_exception(err, false)
        end

        assert_equal span.tags.length, 5 
      end

      def test_record_custom_unraised_exception
        Instrumenter.instance_variable_set(:@ingest_url, "")
        tracer = Instrumenter.new_tracer(service_name: "test-service")
        span = tracer.start_active_span("test span").span
        assert_equal span.tags.length, 2 

        err = CustomError.new("custom err message")
        tracer.record_exception(err)

        assert_equal span.tags.length, 5 
        err_tag, kind_tag, msg_tag = span.tags[2..]
        assert_equal err_tag.key, "error"
        assert_equal err_tag.vBool, true
        assert_equal kind_tag.key, "sfx.error.kind"
        assert_equal kind_tag.vStr, "SignalFx::CustomTracerTest::CustomError"
        assert_equal msg_tag.key, "sfx.error.message"
        assert_equal msg_tag.vStr, "custom err message"
      end
    end
  end
end