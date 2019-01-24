require 'jaeger/client'
# require 'signalfx/tracing/reporter/auto_reviving_async_reporter'
require 'signalfx/tracing/http_sender'
# require 'signalfx/tracing/tracer'
require 'signalfx/tracing/register'
require 'signalfx/tracing/compat'
require 'thread'

module SignalFx
  module Tracing
    module Instrumenter

      class << self

        attr_reader :ingest_url, :service_name, :access_token
        attr_accessor :tracer

        def configure(tracer: nil,
                      ingest_url: ENV['SIGNALFX_INGEST_URL'] || 'https://ingest.signalfx.com/v1/trace',
                      service_name: ENV['SIGNALFX_SERVICE_NAME'] || "signalfx-ruby-tracing",
                      access_token: ENV['SIGNALFX_ACCESS_TOKEN'],
                      auto_instrument: false,
                      fork_safe: false)
          @ingest_url = ingest_url
          @service_name = service_name
          @access_token = access_token
          @fork_safe = fork_safe
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
            # reporter = create_reporter(@http_sender)
            reporter = Jaeger::Client::Reporters::RemoteReporter.new(sender: @http_sender, flush_interval: 1)

            # sampler = Jaeger::Client::Samplers::Const.new(true)

            injectors = {
              OpenTracing::FORMAT_RACK => [Jaeger::Client::Injectors::B3RackCodec]
            }
            extractors = {
              OpenTracing::FORMAT_RACK => [Jaeger::Client::Extractors::B3RackCodec]
            }

            # @tracer = SignalFx::Tracing::Tracer.new(reporter: reporter, sampler: sampler, injectors: injectors, extractors: extractors)
            @tracer = Jaeger::Client.build(
              service_name: service_name,
              reporter: reporter,
              injectors: injectors,
              extractors: extractors
            )
            OpenTracing.global_tracer = @tracer
          else
            @tracer = tracer
          end
        end

        # This method will either use the default reporter, which will not check
        # for the sender thread, or if fork_safe is true then it will create the
        # self-reviving reporter. The main use for this is
        # when the process with the tracer gets forked or goes through some
        # other process that kills child threads.
        def create_reporter(sender)
          if @fork_safe
            # SignalFx::Tracing::AutoRevivingAsyncReporter.new(sender, 1)
            Jaeger::Client::AsyncReporter.create(sender: sender, flush_interval: 1)
          else
            Jaeger::Client::AsyncReporter.create(sender: sender, flush_interval: 1)
          end
        end

        # at the moment this just sets a new reporter in the tracer
        def revive
          @tracer.set_reporter(create_reporter(@http_sender)) if @tracer.respond_to? :set_reporter
        end
      end
    end

    # auto-configure if the correct env var is set
    Instrumenter.configure(auto_instrument: true) if ENV['SIGNALFX_AUTO_INSTRUMENT'] == 'true'
  end
end
