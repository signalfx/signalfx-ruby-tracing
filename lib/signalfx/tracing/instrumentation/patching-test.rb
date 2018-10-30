module SignalFx
  module Tracing
    module Instrumenter
      module PatchingTest

        Register.add_lib :PatchingTest, self

        class << self

          def instrument
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
