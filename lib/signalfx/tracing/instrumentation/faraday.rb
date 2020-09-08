module SignalFx
  module Tracing
    module Instrumenter
      module Faraday

        Register.add_lib :Faraday, self

        class << self
          
          def instrument(opts = {})
            begin
              require 'faraday'
            rescue LoadError
              return
            end

            begin
              require 'faraday/tracer'
            rescue LoadError => e
              puts e.message
              return
            end

            patch_initialize if !@instrumented
            @instrumented = true
          end

          # somewhat messy, but this lets connections be traced without manual
          # configuration to use the middleware
          def patch_initialize
            ::Faraday::Connection.module_eval do
              alias_method :initialize_original, :initialize

              def initialize(url = nil, options = nil, &block)
                # initialize the connection as usual
                initialize_original(url, options, &block)

                # before we let go, add the Faraday tracer to the beginning of the stack
                @builder.insert(0, ::Faraday::Tracer)
              end
            end
          end
        end
      end
    end
  end
end

