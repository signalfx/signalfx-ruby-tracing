require 'signalfx/tracing/register'
require 'signalfx/tracing/patches/patching-test'

module SignalFx
    module Tracing
        module Instrumenter
            class Patch

                def self.configure
                    yield self
                end

                def self.instrument(to_patch)

                    # if this is the first time, include all the available patches
                    if !Register.initialized?
                        Register.include_patches
                    end

                    if Register.available_libs[to_patch].nil?
                        puts "instrumentation not found"
                    else
                        puts "found instrumentation"
                        Register.available_libs[to_patch].patch
                    end
                end
            end
        end
    end
end

