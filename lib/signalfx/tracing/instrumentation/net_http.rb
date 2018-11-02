module SignalFx
  module Tracing
    module Instrumenter
      module NetHttp

        Register.add_lib :NetHttp, self

        class << self

          attr_reader :ingest_uri

          def instrument
            begin
              @ingest_uri = URI.parse(ENV['INGEST_URL'])
            rescue
              puts "Ingest URI not provided"
              @ingest_uri = URI.new
            end

            patch_request
          end

          def patch_request

            ::Net::HTTP.module_eval do 
              alias_method :request_original, :request

              def request(req, body = nil, &block)
                res = ''

                # make an effort to see if this is going out to the ingest url
                if ingest_path?(req)
                  # this is probably a request to export spans, so we should ignore it
                  res = request_original(req, body, &block)
                else
                  tags = {
                    "component" => "Net::HTTP",
                    "span.kind" => "client",
                    "http.method" => req.method,
                    "http.url" => req.path,
                    "peer.host" => @address,
                    "peer.port" => @port,
                  }
                  OpenTracing.global_tracer.start_active_span("#{req.method} #{req.path}", tags: tags) do |scope|
                    # inject the trace in case the remote service can pick it up
                    OpenTracing.inject(scope.span.context, OpenTracing::FORMAT_RACK, req)

                    # call the original request method
                    res = request_original(req, body, &block)

                    # set response code and error if applicable
                    scope.span.set_tag("http.status_code", res.code)
                    scope.span.set_tag("error", true) if res.is_a?(::Net::HTTPClientError)
                  end
                end

                res
              end

              # Compare the ingest uri info with the current request info
              def ingest_path?(req)
                tracer = ::SignalFx::Tracing::Instrumenter::NetHttp.ingest_uri
                return "#{tracer.path}?#{tracer.query}" == req.path &&  # this should short-circuit in most cases 
                  tracer.host == @address &&
                  tracer.port == @port
              end
            end
          end
        end
      end
    end
  end
end
