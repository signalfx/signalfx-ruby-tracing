require 'signalfx/tracing/register'

module SignalFx
    module Tracing
        module Instrumenter
            module Patches
                module PatchingTest
                    class ToPatch

                        def patch

                            ::PatchingTest::ToPatch.class_eval do
                                alias_method :test_old, :test

                                def test
                                    puts "patched test"
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
