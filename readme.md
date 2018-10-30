
# Ruby auto-instrumenter

## Usage

```ruby
SignalFx::Tracing::Instrumenter::Patch.instrument(:LibName)
```

or as a block

```ruby
SignalFx::Tracing::Instrumenter::Patch.configure do |patcher|
    patcher.instrument(:LibName)
end
```

# Instrumentation

Details and configuration for specific frameworks.

## Sinatra

Sinatra instrumentation traces requests and template rendering.

### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Sinatra)
end
```
