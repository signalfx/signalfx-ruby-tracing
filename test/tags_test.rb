require 'test/unit'
require_relative '../lib/signalfx/tracing'
require 'jaeger/thrift_tag_builder'

module SignalFx 
  class StringTest
    def to_s
      return "a very long string represents this class..."
    end
  end

  class TagTest < Test::Unit::TestCase
    require 'test/unit'

    def test_defaults
      assert_equal SignalFx::Tracing::TagBuilder::ClassMethods.max_attr_length, 1200
    end

    def test_max_length
      tag = Jaeger::ThriftTagBuilder.build("k", "hello")
      assert_equal tag.vStr, "hello"

      SignalFx::Tracing::TagBuilder::ClassMethods.max_attr_length = 2
      tag = Jaeger::ThriftTagBuilder.build("k", "hello")
      assert_equal tag.vStr, "he"

      SignalFx::Tracing::TagBuilder::ClassMethods.max_attr_length = 1000
      tag = Jaeger::ThriftTagBuilder.build("k", StringTest.new)
      assert_equal tag.vStr, "a very long string represents this class..."

      SignalFx::Tracing::TagBuilder::ClassMethods.max_attr_length = 5
      tag = Jaeger::ThriftTagBuilder.build("k", StringTest.new)
      assert_equal tag.vStr, "a ver"
    end
  end
end
