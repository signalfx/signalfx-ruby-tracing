require 'jaeger/client'
require 'jaeger/client/http_sender'

require 'signalfx/tracing/register'

module SignalFx
  module Tracing
    module Instrumenter

      class << self

        attr_reader :ingest_url

        def configure(tracer: nil,
                      ingest_url: "https://ingest.signalfx.com/v1/trace")
          @ingest_url = ingest_url
          set_tracer(tracer)
          yield self
        end

        def instrument(to_patch)
          if Register.available_libs[to_patch].nil?
            puts "instrumentation not found"
          else
            Register.available_libs[to_patch].instrument
          end
        end

        def set_tracer(tracer)
          # build a new tracer if one wasn't provided
          if tracer.nil?
            access_token = ENV['SIGNALFX_ACCESS_TOKEN']
            service_name = ENV['SERVICE_NAME']
            headers = { "X-SF-Token" => access_token }
            encoder = Jaeger::Client::Encoders::ThriftEncoder.new(service_name: service_name)
            http_sender = Jaeger::Client::HttpSender.new(url: @ingest_url, headers: headers, encoder: encoder)

            @tracer = Jaeger::Client.build(service_name: service_name, sender: http_sender)
            OpenTracing.global_tracer = @tracer
          else
            @tracer = tracer
          end
        end
      end
    end
  end
end
