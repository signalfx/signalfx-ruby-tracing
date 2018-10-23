
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
