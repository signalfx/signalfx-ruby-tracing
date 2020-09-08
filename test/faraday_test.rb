require 'test/unit'
require 'faraday'
require_relative '../lib/signalfx/tracing'

SignalFx::Tracing::Instrumenter.configure do |p|
  p.instrument(:Faraday)
end

module SignalFx 

  class FaradayTest < Test::Unit::TestCase
    # require to make sure instrumentation is installed and applied
    require 'faraday/tracer'

    def test_span
      c = Faraday.new(url: "https://example.com") do |conn|
        conn.adapter :em_synchrony
        conn.request :url_encoded
        conn.basic_auth("username", "password")
      end
       assert c.headers.has_key? 'User-Agent'
       assert c.headers.has_key? 'Authorization'
    end
  end
end
