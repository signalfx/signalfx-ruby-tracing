module SignalFx
  module Tracing
    module Instrumenter
      module Sinatra

        Register.add_lib :Sinatra, self

        class << self

          def instrument
            puts "patching sinatra"
          end
        end
      end

    end
  end
end
