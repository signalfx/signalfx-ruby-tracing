require 'jaeger/client'
require 'signalfx/tracing/http_sender'
require 'signalfx/tracing/register'
require 'thread'

module SignalFx
  module Tracing
    module Instrumenter

      class << self

        attr_reader :ingest_url

        def configure(tracer: nil,
                      ingest_url: ENV['SIGNALFX_INGEST_URL'] || 'https://ingest.signalfx.com/v1/trace',
                      service_name: ENV['SIGNALFX_SERVICE_NAME'] || "signalfx-ruby-tracing",
                      access_token: ENV['SIGNALFX_ACCESS_TOKEN'])
          @ingest_url = ingest_url
          set_tracer(tracer: tracer, service_name: service_name, access_token: access_token)
          yield self
        end

        def instrument(to_patch, **args)
          if Register.available_libs[to_patch].nil?
            puts "instrumentation not found"
          else
            Register.available_libs[to_patch].instrument(**args)
          end
        end

        def set_tracer(tracer: nil, service_name: nil, access_token: nil)
          # build a new tracer if one wasn't provided
          if tracer.nil?
            headers = { "X-SF-Token" => access_token }
            encoder = Jaeger::Client::Encoders::ThriftEncoder.new(service_name: service_name)

            call_before = lambda { Thread.current.thread_variable_set(:http_sender_thread, true) }
            call_after = lambda { Thread.current.thread_variable_set(:http_sender_thread, nil) }
            http_sender = SignalFx::Tracing::HttpSenderWithFlag.new(url: @ingest_url, headers: headers, encoder: encoder, call_before: call_before, call_after: call_after)

            @tracer = Jaeger::Client.build(service_name: service_name, sender: http_sender, flush_interval: 1)
            OpenTracing.global_tracer = @tracer
          else
            @tracer = tracer
          end
        end
      end
    end
  end
end
