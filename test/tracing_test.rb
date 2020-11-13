require 'test/unit'
require 'jaeger/client'

require_relative '../lib/signalfx/tracing'

module SignalFx 
  class TracingTests 

    class SetupTest < Test::Unit::TestCase
      require 'test/unit'

      Instrumenter = SignalFx::Tracing::Instrumenter

      def test_span_tags
        tags = Instrumenter.process_span_tags()
        assert_equal tags, {}

        tags = Instrumenter.process_span_tags({"k1" => "v1"})
        assert_equal tags, {"k1" => "v1"}

        ENV['SIGNALFX_SPAN_TAGS'] = 'k2:v2,kk:vv'
        tags = Instrumenter.process_span_tags({"k1" => "v1"})
        assert_equal tags, {
          "k1" => "v1",
          "k2" => "v2",
          "kk" => "vv",
        }

        ENV['SIGNALFX_SPAN_TAGS'] = ''
      end
          
    end
  end
end