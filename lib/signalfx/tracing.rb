require 'signalfx/tracing/register'

module SignalFx
    module Tracing
        module Instrumenter
            class << self

                def configure
                    yield self
                end

                def instrument(to_patch)
                    if Register.available_libs[to_patch].nil?
                        puts "instrumentation not found"
                    else
                        Register.available_libs[to_patch].instrument
                    end

                    puts Register.available_libs
                end
            end
        end
    end
end
