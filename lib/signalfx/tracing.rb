require 'jaeger/client'
require 'jaeger/client/http_sender'

require 'signalfx/tracing/register'

module SignalFx
  module Tracing
    module Instrumenter

      class << self

        attr_reader :ingest_url

        def configure(tracer: nil,
                      ingest_url: ENV['SIGNALFX_INGEST_URL'] || 'https://ingest.signalfx.com/v1/trace',
                      service_name: ENV['SIGNALFX_SERVICE_NAME'] || "signalfx-ruby-tracing",
                      access_token: ENV['SIGNALFX_ACCESS_TOKEN'],
                      auto_configure: false)
          @ingest_url = ingest_url
          set_tracer(tracer: tracer, service_name: service_name, access_token: access_token)
          if auto_configure
            Register.available_libs.each_pair do |key, value|
              value.instrument
            end
          else
            yield self
          end
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
