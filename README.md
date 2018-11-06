# Ruby auto-instrumenter

## Usage

```ruby
SignalFx::Tracing::Instrumenter.instrument(:LibName)
```

or as a block

```ruby
SignalFx::Tracing::Instrumenter.configure do |patcher|
    patcher.instrument(:LibName)
end
```

`configure` accepts several optional parameters:
- `tracer`: a preconfigured OpenTracing tracer to use. If one is not provided,
  a new tracer will be initialized. Default: `nil`
- `ingest_url`: this is the endpoint to which spans are sent by the tracer.
  Default: `https://ingest.signalfx.com/v1/trace`
- `service_name`: service name to send spans under.
  Default: `signalfx-ruby-tracing`
- `access_token`: SignalFx access token for authentication. Default: `''`

Environment variables can be used to configure `service_name` and `access_token`
if not given to the `configure` method.

```bash
export SIGNALFX_ACCESS_TOKEN="<token>"
export SERVICE_NAME="<service_name>"
```

If these environment variables are not set, the values will default to the ones
listed above.

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

## Sinatra

Sinatra instrumentation traces requests and template rendering. The instrumenter
registers a Sinatra extension that uses `rack-tracer` to trace requests and
monkey-patches to trace view rendering.

The source for this instrumentation is located [here](https://github.com/signalfx/sinatra-tracer).

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Sinatra)
end
```

