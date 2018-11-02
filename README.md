
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

# Instrumentation

Details and configuration for specific frameworks.

## Active Record

This instrumentation creates spans for each Active Record query using the Active
Support notifications framework.

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

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Faraday)
end
```

## Net::HTTP

This automatically traces all requests using Net::HTTP.

### Usage

Before using, configure the environment:

```bash
export TRACER_INGEST_URL=<ingest_url>
```

Then in the code:

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:NetHttp)
end
```

## Rack

Rack spans are created using the `rack-tracer` gem. This is enabled
automatically for other frameworks that are built on top of Rack, but it can
also be separately enabled.

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Rack)
end
```

## Sinatra

Sinatra instrumentation traces requests and template rendering.

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Sinatra)
end
```

