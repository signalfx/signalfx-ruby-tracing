# Ruby auto-instrumenter

## Usage

Configure the instrumentation anywhere in the setup portion of your code or before doing anything
that needs to be traced. For example, in `config/initializers/tracing.rb` for Rails.

This can be done automatically, where the auto-instrumenter will check for
modules defined in the code and instrument them if available:

```ruby
SignalFx::Tracing::Instrumenter.configure(auto_instrument:true)
```

or manually in a block:

```ruby
SignalFx::Tracing::Instrumenter.configure do |patcher|
    patcher.instrument(:LibName)
    ...
end
```

`configure` accepts several optional parameters:
- `tracer`: a preconfigured OpenTracing tracer to use. If one is not provided,
  a new tracer will be initialized.
  - Default: `nil`
- `ingest_url`: this is the endpoint to which spans are sent by the tracer.
  - Default: `https://ingest.signalfx.com/v1/trace`
- `service_name`: service name to send spans under.
  - Default: `signalfx-ruby-tracing`
- `access_token`: SignalFx access token for authentication.
  - Default: `''`

Environment variables can be used to configure `service_name` and `access_token`
if not given to the `configure` method.

```bash
export SIGNALFX_ACCESS_TOKEN="<token>"
export SIGNALFX_SERVICE_NAME="<service_name>"
export SIGNALFX_INGEST_URL="<url>"
```

If these environment variables are not set, the values will default to the ones
listed above.

The `access_token` or `SIGNALFX_ACCESS_TOKEN` only needs to be set when sending
spans to a SignalFx ingest directly. It is not required when using the Smart
Agent or Smart Gateway.

# Instrumentation

Details and configuration for specific frameworks.

## Active Record

This instrumentation creates spans for each Active Record query using the Active
Support notifications framework.

The source for this instrumentation is located [here](https://github.com/salemove/ruby-activerecord-opentracing).

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:ActiveRecord)
end
```

## Elasticsearch

Elasticsearch queries through the Ruby client are traced using a wrapper around
the transport.

The source for the instrumentation is located [here](https://github.com/iaintshine/ruby-elasticsearch-tracer).

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Elasticsearch, auto_instrument: true)
end
```

When the `auto_instrument` option is `true`, it will allow all new Elasticsearch
clients to automatically wrap the default or configured transport and get
traces for queries. No additional configuration is necessary.

Alternatively, the instrumentation can be used selectively by setting a custom
transport on the clients to be traced manually:

```ruby
require 'elasticsearch'
require 'elasticsearch-tracer'

client = Elasticsearch::TracingClient.new
client.transport = Elasticsearch::Tracer::Transport.new(tracer: OpenTracing.global_tracer,
                                                        active_span: -> { OpenTracing.global_tracer.active_span },
                                                        transport: client.transport)
```

## Faraday

Faraday HTTP client instrumentation automatically creates spans for outgoing
requests. If the remote service has instrumentation that is aware of Rack,
those spans will be automatically nested with Faraday's spans.

The source for this instrumentation is located [here](https://github.com/opentracing-contrib/ruby-faraday-tracer).

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Faraday)
end
```

To use the instrumentation directly without patching, the Faraday middleware
must be inserted for each new connection:
```ruby
conn = Faraday.new(url: 'http://localhost:3000/') do |faraday|
  faraday.use Faraday::Tracer
end
```

For more detailed usage, please check the instrumenation's page.

## Net::HTTP

This automatically traces all requests using Net::HTTP.

The source for this instrumentation is located [here](https://github.com/signalfx/net-http-tracer).

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:NetHttp)
end
```

## Rack

Rack spans are created using the `rack-tracer` gem. This is enabled
automatically for other frameworks that are built on top of Rack, but it can
also be separately enabled.

The source for this instrumentation is located [here](https://github.com/opentracing-contrib/ruby-rack-tracer).

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Rack)
end
```

## Rails

Rails applications can be traced using the notifications provided by ActiveSupport.
It can use `rack-tracer` to trace by requests, or it'll try to group spans by
request ID.

The source for this instrumentation is located [here](https://github.com/achandras/ruby-rails-tracer).

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Rails)
end
```

Optionally, to disable Rack instrumentation, set the `rack_tracer` field to false.

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Rails, rack_tracer: false)
end
```

## RestClient

RestClient requests can be patched to automatically be wrapped in a span. It
will also inject the span context so remote services can extract it.

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:RestClient)
end
```

## Sinatra

Sinatra instrumentation traces requests and template rendering. The instrumenter
registers a Sinatra extension that uses `rack-tracer` to trace requests and
monkey-patches to trace view rendering. Rack instrumentation is automatically
enabled when using Sinatra instrumentation.

The source for this instrumentation is located [here](https://github.com/signalfx/sinatra-tracer).

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Sinatra)
end
```

