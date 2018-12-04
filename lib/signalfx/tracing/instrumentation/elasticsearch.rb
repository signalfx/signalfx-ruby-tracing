module SignalFx
  module Tracing
    module Instrumenter
      module Elasticsearch

        Register.add_lib :Elasticsearch, self

        class << self

          attr_reader :instrumented

          def instrument(opts = {})
            return if @instrumented

            begin
              require 'elasticsearch'
            rescue LoadError
              return
            end

            require 'elasticsearch-tracer'

            patch_new if opts.fetch(:auto_instrument, false)

            # prevent re-instrumenting
            @instrumented = true
          end

          def patch_new
            ::Elasticsearch::Client.module_eval do
              alias_method :new_original, :new

              def new(arguments = {}, &block)
                # create a new TracingClient, which is almost identical to the
                # default client, and add the tracing transport afterwards. This
                # allows us to maintain the original transport if the user has
                # specified a non-default transport
                client = ::Elasticsearch::Tracer::TracingClient.new(arguments, &block)
                client.transport = ::Elasticsearch::Tracer::Transport.new(tracer: OpenTracing.global_tracer,
                                                                          active_span: -> { OpenTracing.global_tracer.active_span },
                                                                          transport: client.transport)

                return client
              end
            end
          end

        end
      end
    end
  end
end
