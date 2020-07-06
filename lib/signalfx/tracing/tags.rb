require 'jaeger/span'

module SignalFx
  module Tracing
    module TagBuilder
      def self.prepended(base)
        base.singleton_class.prepend(ClassMethods)
      end

      module ClassMethods
        @@max_attr_length = (ENV['SIGNALFX_RECORDED_VALUE_MAX_LENGTH'] || '1200').to_i

        def self.max_attr_length
          @@max_attr_length
        end

        def self.max_attr_length=(v)
          @@max_attr_length = v
        end

        def _truncate_value_if_needed(value)
          if value.is_a? String
            if @@max_attr_length > 0
              value = value[0..@@max_attr_length-1]
            end
          end
          return value
        end

        def build(key, value)
          tag = super(key, value)
          if tag.vStr != nil
            tag.vStr = _truncate_value_if_needed(tag.vStr)
          end
          tag
        end
      end
    end
  end
end


module Jaeger
  class ThriftTagBuilder
    prepend SignalFx::Tracing::TagBuilder
  end
end
