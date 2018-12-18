module SignalFx
  module Tracing
    module Compat
      def self.apply
        @compat.each { |mod| mod.apply } if @compat
      end

      def self.add_compat(mod)
        @compat = [] unless @compat
        @compat.push(mod)
      end
    end
  end
end

require 'signalfx/tracing/compat/phusion_passenger'
