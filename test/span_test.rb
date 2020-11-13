require 'test/unit'
require 'jaeger/client'

require_relative '../lib/signalfx/tracing'

module SignalFx 
  class Span 

    class SpanTest < Test::Unit::TestCase
      require 'test/unit'

      Instrumenter = SignalFx::Tracing::Instrumenter

      def test_span_tags
        Instrumenter.instance_variable_set(:@ingest_url, "")
        Instrumenter.new_tracer(service_name: "test-service") 
        tags = Instrumenter.reporter.instance_variable_get(:@sender).instance_variable_get(:@encoder).instance_variable_get(:@tags)
        assert_equal tags.length, 3

        Instrumenter.new_tracer(service_name: "test-service", span_tags: {"t1": "v1", "t2": "v2"})
        tags = Instrumenter.reporter.instance_variable_get(:@sender).instance_variable_get(:@encoder).instance_variable_get(:@tags)
        assert_equal tags.length, 5
        tag = tags[0]
        assert_equal tag.key, "t1"
        assert_equal tag.vStr, "v1"

        tag = tags[1]
        assert_equal tag.key, "t2"
        assert_equal tag.vStr, "v2"
      end
          
    end
  end
end