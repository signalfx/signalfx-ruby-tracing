require 'jaeger/client'
require 'jaeger/samplers'
require 'jaeger/injectors'
require 'jaeger/extractors'
require 'signalfx/tracing/http_sender'
require 'signalfx/tracing/register'
require 'signalfx/tracing/compat'
require 'signalfx/tracing/sfx_logger'
require 'signalfx/tracing/tags'
require 'signalfx/tracing/tracer'
require 'signalfx/tracing/span'
require 'thread'

module SignalFx
  module Tracing
    module Instrumenter

      class << self

        attr_reader :ingest_url, :service_name, :access_token
        attr_accessor :tracer, :reporter

        def configure(tracer: nil,
                      ingest_url: ENV['SIGNALFX_ENDPOINT_URL'] || ENV['SIGNALFX_INGEST_URL'] || 'http://localhost:9080/v1/trace',
                      service_name: ENV['SIGNALFX_SERVICE_NAME'] || "signalfx-ruby-tracing",
                      access_token: ENV['SIGNALFX_ACCESS_TOKEN'],
                      auto_instrument: false,
                      span_tags: {})
          @ingest_url = ingest_url
          @service_name = service_name
          @access_token = access_token

          span_tags = process_span_tags(span_tags)
          set_tracer(tracer: tracer, service_name: service_name, access_token: access_token, span_tags: span_tags) if @tracer.nil?

          if auto_instrument
            Register.available_libs.each_pair do |key, value|
              begin
                value.instrument
              rescue Exception => e
                logger.error { "failed to initialize instrumentation '#{key}': #{e.inspect}" }
                logger.error { e.backtrace }
              end
            end
          else
            yield self
          end

          Compat.apply
        end

        def process_span_tags(span_tags={})
          span_tags_string = ENV['SIGNALFX_SPAN_TAGS']
          if not span_tags_string.nil?
            span_tags_string.split(',').each do |t|
              k, v = t.strip.split(':')
              span_tags[k] = v
            end
          end
          return span_tags
        end

        def instrument(to_patch, **args)
          if Register.available_libs[to_patch].nil?
            logger.error { "instrumentation not found: #{to_patch}" }
          else
            begin
              Register.available_libs[to_patch].instrument(**args)
            rescue Exception => e
              logger.error { "failed to initialize instrumentation '#{to_patch}': #{e.inspect}" }
              logger.error { e.backtrace }
            end
          end
        end

        def new_tracer(service_name: nil, access_token: nil, span_tags: {})
          # build a new tracer if one wasn't provided
          headers = {}

          # don't set the header if no token was provided
          headers["X-SF-Token"] = access_token if access_token && !access_token.empty?

          encoder = Jaeger::Client::Encoders::ThriftEncoder.new(service_name: service_name, tags: span_tags)
          @http_sender = SignalFx::Tracing::HttpSenderWithFlag.new(url: @ingest_url, headers: headers, encoder: encoder)
          @reporter = Jaeger::Client::Reporters::RemoteReporter.new(sender: @http_sender, flush_interval: 1)

          injectors = {
            OpenTracing::FORMAT_RACK => [Jaeger::Client::Injectors::B3RackCodec],
            OpenTracing::FORMAT_TEXT_MAP => [Jaeger::Client::Injectors::B3RackCodec]
          }
          extractors = {
            OpenTracing::FORMAT_RACK => [Jaeger::Client::Extractors::B3RackCodec],
            OpenTracing::FORMAT_TEXT_MAP => [Jaeger::Client::Extractors::B3TextMapCodec]
          }

          Tracer.new(
            reporter: reporter,
            sampler: Jaeger::Samplers::Const.new(true),
            injectors: Jaeger::Injectors.prepare(injectors),
            extractors: Jaeger::Extractors.prepare(extractors)
          )
        end

        def set_tracer(tracer: nil, service_name: nil, access_token: nil, span_tags: {})
          # build a new tracer if one wasn't provided
          if tracer.nil?
            @tracer = new_tracer(service_name: service_name, access_token: access_token, span_tags: span_tags)
            OpenTracing.global_tracer = @tracer
          else
            @tracer = tracer
          end
        end

        def revive
          set_tracer(service_name: @service_name, access_token: @access_token)
        end

        def logger()
          if @_logger == nil
            @_logger = Logging.logger
          end
          return @_logger
        end
      end
    end

    # auto-configure if the correct env var is set
    Instrumenter.configure(auto_instrument: true) if ENV['SIGNALFX_AUTO_INSTRUMENT'] == 'true'
  end
end
