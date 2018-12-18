# Ruby auto-instrumenter

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'signalfx-tracing'
```

and then execute:

```bash
$ bundle install
```

## Usage

Configure the instrumentation anywhere in the setup portion of your code or before doing anything
that needs to be traced.

For Rails, this would go in `config/initializer/tracing.rb`.

The instrumentation can be done automatically, where the auto-instrumenter will
check for modules defined in the code and instrument them if available:

```ruby
SignalFx::Tracing::Instrumenter.configure(auto_instrument:true)
```

Manual configuration may be desirable when only some libraries should be traced.
These instrumentations to can be selected in a block:

```ruby
SignalFx::Tracing::Instrumenter.configure do |patcher|
    patcher.instrument(:LibName)
    ...
end
```

Valid lib names are listed below with the instrumentation documentation.

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
- `fork_safe`: If `true`, makes the tracer safe to fork if events cannot
  be controlled
  - Default: `false`

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

This section contains details and configuration for specific frameworks.

### Runtimes

- MRI Ruby (CRuby) 2.0+

### Web servers

- Puma >= 3.0.0
- Passenger >= 5.0.25

### Libraries/Frameworks

| Library       | Versions Supported |
| ------------- | ------------------ |
| ActiveRecord  | > 3.2              |
| Elasticsearch | >= 5.x             |
| Faraday       | > 0.9.2            |
| Mongo         | >= 2.1             |
| Mysql2        | >= 0.5.0           |
| Net::HTTP     | Ruby > 2.0         |
| Rack          | >= 2.0             |
| Rails         | >= 4.2.0           |
| REST Client   | >= 2.0.0           |
| Sinatra       | >= 1.1.4           |

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

The forked source for the instrumentation is located [here](https://github.com/signalfx/ruby-elasticsearch-tracer).

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

For more detailed usage, please check the instrumentation's page.

## Mongo

Mongo driver instrumentation traces queries performed through the Ruby Mongodb driver.

The source for this instrumentation is located [here](https://github.com/signalfx/ruby-mongodb-instrumentation)

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:MongoDB)
end
```

## Mysql2

Mysql2 instrumentation traces all queries performed with the Mysql2 client.

The source for this instrumentation is located [here](https://github.com/signalfx/ruby-mysql2-instrumentation)

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Mysql2)
end
```

## Net::HTTP

This automatically traces all requests using Net::HTTP.

The source for this instrumentation is located [here](https://github.com/signalfx/ruby-net-http-instrumentation).

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:NetHttp, tracer: tracer)
end
```

An optional `tracer` named argument can be provided to use a custom tracer. It will default to `OpenTracing.global_tracer` if not provided.

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

The forked source for this instrumentation is located [here](https://github.com/signalfx/ruby-rails-tracer).

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

Note that if `rack_tracer` is set to `false`, requests propagated to the Rails
app will not be extracted. For example, if a traced service makes a request to
an endpoint served by the Rails app, it will not be automatically nested.

## RestClient

RestClient requests can be patched to automatically be wrapped in a span. It
will also inject the span context so remote services can extract it.

The source for this instrumentation is located [here](https://github.com/signalfx/ruby-restclient-instrumentation).

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:RestClient, tracer: tracer, propagate: true)
end
```

Arguments:
- `tracer`: Optional custom tracer to use for this instrumentation
  - Default: `OpenTracing.global_tracer`
- `propagate`: Propagate spans to the request endpoint.
  - Default: `false`

## Sinatra

Sinatra instrumentation traces requests and template rendering. The instrumenter
registers a Sinatra extension that uses `rack-tracer` to trace requests and
monkey-patches to trace view rendering. Rack instrumentation is automatically
enabled when using Sinatra instrumentation.

The source for this instrumentation is located [here](https://github.com/signalfx/ruby-sinatra-instrumentation).

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Sinatra)
end
```

## Troubleshooting

### Forking

If spans are no longer sent after forking a process, the span reporter thread
has been lost while copying to the process.

The reporter can be revived by calling `SignalFx::Tracing::Instrumenter.revive`
in the newly created process.

When the new process can't be handled directly, setting `fork_safe: true`
when configuring the instrumentation will use a reporter that checks and revives
itself every time a span is reported.

