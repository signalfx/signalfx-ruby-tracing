require 'jaeger/client'
require 'signalfx/tracing/http_sender'
require 'signalfx/tracing/register'
require 'signalfx/tracing/compat'
require 'thread'

module SignalFx
  module Tracing
    module Instrumenter

      class << self

        attr_reader :ingest_url, :service_name, :access_token
        attr_accessor :tracer, :reporter

        def configure(tracer: nil,
                      ingest_url: ENV['SIGNALFX_INGEST_URL'] || 'https://ingest.signalfx.com/v1/trace',
                      service_name: ENV['SIGNALFX_SERVICE_NAME'] || "signalfx-ruby-tracing",
                      access_token: ENV['SIGNALFX_ACCESS_TOKEN'],
                      auto_instrument: false)
          @ingest_url = ingest_url
          @service_name = service_name
          @access_token = access_token
          set_tracer(tracer: tracer, service_name: service_name, access_token: access_token)

          if auto_instrument
            Register.available_libs.each_pair do |key, value|
              value.instrument
            end
          else
            yield self
          end

          Compat.apply
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
            headers = {}

            # don't set the header if no token was provided
            headers["X-SF-Token"] = access_token if access_token && !access_token.empty?

            encoder = Jaeger::Client::Encoders::ThriftEncoder.new(service_name: service_name)
            @http_sender = SignalFx::Tracing::HttpSenderWithFlag.new(url: @ingest_url, headers: headers, encoder: encoder)
            @reporter = Jaeger::Client::Reporters::RemoteReporter.new(sender: @http_sender, flush_interval: 1)

            injectors = {
              OpenTracing::FORMAT_RACK => [Jaeger::Client::Injectors::B3RackCodec]
            }
            extractors = {
              OpenTracing::FORMAT_RACK => [Jaeger::Client::Extractors::B3RackCodec]
            }

            @tracer = Jaeger::Client.build(
              service_name: service_name,
              reporter: @reporter,
              injectors: injectors,
              extractors: extractors
            )
            OpenTracing.global_tracer = @tracer
          else
            @tracer = tracer
          end
        end

        def revive
          set_tracer(service_name: @service_name, access_token: @access_token)
        end
      end
    end

    # auto-configure if the correct env var is set
    Instrumenter.configure(auto_instrument: true) if ENV['SIGNALFX_AUTO_INSTRUMENT'] == 'true'
  end
end
