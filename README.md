
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

## Sinatra

Sinatra instrumentation traces requests and template rendering.

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Sinatra)
end
```

