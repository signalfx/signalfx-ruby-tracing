module SignalFx
  module Tracing
    module Client
      include ::Jaeger::Client 

      def self.build(host: '127.0.0.1',
                     port: 6831,
                     service_name:,
                     flush_interval: DEFAULT_FLUSH_INTERVAL,
                     sampler: Samplers::Const.new(true),
                     logger: Logger.new(STDOUT),
                     sender: nil,
                     reporter: nil,
                     injectors: {},
                     extractors: {},
                     tags: {})
        encoder = Encoders::ThriftEncoder.new(service_name: service_name, tags: tags)

        if sender
          warn '[DEPRECATION] Passing `sender` directly to Jaeger::Client.build is deprecated.' \
          'Please use `reporter` instead.'
        end

        reporter ||= Reporters::RemoteReporter.new(
          sender: sender || UdpSender.new(host: host, port: port, encoder: encoder, logger: logger),
          flush_interval: flush_interval
        )

        Tracer.new(
          reporter: reporter,
          sampler: sampler,
          injectors: Injectors.prepare(injectors),
          extractors: Extractors.prepare(extractors)
        )
      end
    end
  end
end