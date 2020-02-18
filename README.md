# SignalFx-Tracing Library for Ruby: An OpenTracing Auto-Instrumentor

This utility provides users with the ability of automatically configuring OpenTracing community-contributed [instrumentation libraries](https://github.com/opentracing-contrib) for their Ruby application via a single function.

```ruby
require 'signalfx/tracing'

SignalFx::Tracing::Instrumenter.configure(auto_instrument:true)
```

## Installation

### General installation

```bash
$ gem install signalfx-tracing
```

The SignalFx Tracing Library for Ruby requires just enough dependencies to allow custom instrumentation for your application, with target library instrumentations needing to be installed manually.
The basic installation provides an `sfx-rb-trace-bootstrap` executable to assist with this process, which allows you to specify the desired libraries for instrumentation as a comma-separated list:

```bash
$ sfx-rb-trace-bootstrap --install-deps rack,rails,activerecord,restclient
$ # use the --list option to see all available instrumentations
$ sfx-rb-trace-bootstrap --list
Available target libraries:
{"activerecord"=>["activerecord-opentracing", "~> 0.2.1"],
 < ... >
 "sinatra"=>["sinatra-instrumentation", "~> 0.1.2"]}
 ```

If you'd prefer to install all the available instrumentations without the assistance of the `sfx-rb-trace-bootstrap` utility, please install the provided [gem dependencies](./gem.deps.rb).

```bash
$ # Run from a cloned and updated https://github.com/signalfx/signalfx-ruby-tracing.git
$ cd signalfx-ruby-tracing
$ bundle install
$ gem install -g
```

### Installation in existing application

Specify the desired dependency by adding this line to your application's Gemfile:

```ruby
gem 'signalfx-tracing'
```

Then execute the following (or use your desired installation method for your application).

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
require 'signalfx/tracing'

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
- `ingest_url`: this is the Smart Agent or Smart Gateway endpoint to which spans are sent by the tracer.
  - Default: `http://localhost:9080/v1/trace`
- `service_name`: service name to send spans under.
  - Default: `signalfx-ruby-tracing`
- `access_token`: SignalFx access token for authentication.  Unnecessary for most deployments.
  - Default: `''`

Environment variables can be used to configure `service_name` and `access_token`
if not given to the `configure` method.

```bash
export SIGNALFX_SERVICE_NAME="<service_name>"
export SIGNALFX_ENDPOINT_URL="<url>"
export SIGNALFX_ACCESS_TOKEN="<token>"
```

If these environment variables are not set, the values will default to the ones
listed above.

# Instrumentation

This section contains details and configuration for specific frameworks.

### Runtimes

- MRI Ruby (CRuby) 2.0+

### Web servers

- Puma >= 3.0.0
- Passenger >= 5.0.25

Instrumentation for routes using these web servers is provided through Rack.
If using a framework that builds on top of Rack, such as Rails or Sinatra, our
instrumentation includes Rack instrumentation. In these cases, the routes
through the web server will be automatically traced.

When interfacing with these web servers as a Rack application, please configure
[Rack instrumentation](#rack) and insert it as middleware.

### Libraries/Frameworks

| Library                             | Versions Supported |
| ----------------------------------- | ------------------ |
| [ActiveRecord](#active-record)      | ~> 5.0             |
| [Elasticsearch](#elasticsearch)     | >= 6.0.2           |
| [Faraday](#faraday)                 | >= 0.9.0           |
| [Grape](#grape)                     | >= 0.13.0          |
| [Mongo](#mongo)                     | >= 2.1.0           |
| [Mysql2](#mysql2)                   | >= 0.4.0           |
| [Net::HTTP](#nethttp)               | Ruby >= 2.0        |
| [Pg](#pg)                           | >= 0.18.0          |
| [Rack](#rack)                       | >= 0.1             |
| [Rails](#rails)                     | >= 3.0.0           |
| [Redis](#redis)                     | >= 4.0.0           |
| [RestClient](#restclient)           | >= 1.5.0           |
| [Sequel](#sequel)                   | >= 3.47.0          |
| [Sidekiq](#sidekiq)                 | >= 0.7.0           |
| [Sinatra](#sinatra)                 | >= 1.0.0           |

## Active Record

This instrumentation creates spans for each Active Record query using the Active
Support notifications framework.

The source for this instrumentation is located [here](https://github.com/salemove/ruby-activerecord-opentracing).

### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i activerecord
```

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

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i elasticsearch
```

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

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i faraday
```

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

## Grape

This instrumentation subscribes to ActiveSupport notifications emitted by the
Grape API. It patches `Grape::API` to automatically insert the `Rack::Tracer`
middleware and trace requests.

The source for this instrumentation is located [here](https://github.com/signalfx/ruby-grape-instrumentation)

### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i grape
```

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Grape)
end
```

`instrument` takes these optional arguments:
- `tracer`: custom tracer to use. Defaults to `OpenTracing.global_tracer`
- `parent_span`: parent span to group spans or block that returns a span. Default: `nil`
- `disable_patching`: disable patching if managing the middleware stack manually. Default: `false`

If patching is disabled, but spans nested by request are still desired, then the
Rack middleware must be manually added to the API class.

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i rack
```

```ruby
require 'rack/tracer'

class MyAPI << Grape::API
  insert 0, Rack::Tracer
  ...
end
```

Please see the instrumentation's page for more details.

## Mongo

Mongo driver instrumentation traces queries performed through the Ruby Mongodb driver.

The source for this instrumentation is located [here](https://github.com/signalfx/ruby-mongodb-instrumentation)

### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i mongodb
```

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:MongoDB)
end
```

## Mysql2

Mysql2 instrumentation traces all queries performed with the Mysql2 client.

The source for this instrumentation is located [here](https://github.com/signalfx/ruby-mysql2-instrumentation)

### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i mysql2
```

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

## Pg

Pg instrumentation traces all queries performed with the pg client.

The source for this instrumentation is located [here](https://github.com/signalfx/ruby-pg-instrumentation)

### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i pg
```

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:pg)
end
```
## Rack

Rack spans are created using the `rack-tracer` gem. This is enabled
automatically for other frameworks that are built on top of Rack, but it can
also be separately enabled.

The source for this instrumentation is located [here](https://github.com/opentracing-contrib/ruby-rack-tracer).

### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i rack
```

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Rack)
end

use Rack::Tracer
```

## Rails

Rails applications can be traced using the notifications provided by ActiveSupport.
It will use `rack-tracer` to trace by requests.

The forked source for this instrumentation is located [here](https://github.com/signalfx/ruby-rails-instrumentation).

### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i rails
```

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Rails)
end
```

Optionally, to disable Rack instrumentation, set the `rack_tracer` field to false.

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Rails, rack_tracer: false, exclude_events: [])
end
```

By default, all Rails ActiveSupport notifications are traced. However, if this
is too noisy, events to ignore can be passed as an array as `exclude_events`.
A full list of events can be seen on the instrumentation's Readme.

Note that if `rack_tracer` is set to `false`, requests propagated to the Rails
app will not be extracted. For example, if a traced service makes a request to
an endpoint served by the Rails app, it will not be automatically nested.

## Redis

This instrumentation traces commands performed using the [Redis client](https://github.com/redis/redis-rb).

The source for this instrumentation is located [here](https://github.com/signalfx/ruby-redis-instrumentation).

### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i redis
```

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Redis, tracer: tracer)
end
```

Arguments:
- `tracer`: Optional custom tracer to use for this instrumentation
  - Default: `OpenTracing.global_tracer`

## RestClient

RestClient requests can be patched to automatically be wrapped in a span. It
will also inject the span context so remote services can extract it.

The source for this instrumentation is located [here](https://github.com/signalfx/ruby-restclient-instrumentation).

### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i restclient
```

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

## Sequel

Sequel instrumentation adds extensions to the Database and Dataset to trace queries.

The source for this instrumentation is located [here](https://github.com/signalfx/ruby-sequel-instrumentation).

### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i sequel
```

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Sequel)
end
```

Arguments:
- `tracer`: Optional custom tracer for this instrumentation
  - Default: `OpenTracing.global_tracer`

## Sidekiq

Sidekiq instrumentation traces worker job submissions and execution via [Sidekiq middleware](https://github.com/mperham/sidekiq/wiki/Middleware).
The instrumenter registers both client and server middleware that use job metadata to
represent all job submissions and their invocations.  Trace context propagation adds
to this job metadata to unifiy distributed client and server requests and processing.

The source for this instrumentation is located [here](https://github.com/signalfx/ruby-sidekiq-tracer).

### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i sidekiq
```

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Sidekiq, propagate: false)
end
```

Arguments:
- `tracer`: Optional custom tracer for this instrumentation
  - Default: `OpenTracing.global_tracer`
- `propagate`: Optional boolean to enable/disable trace context injection via job metadata
  - Default: `true`


## Sinatra

Sinatra instrumentation traces requests and template rendering. The instrumenter
registers a Sinatra extension that uses `rack-tracer` to trace requests and
monkey-patches to trace view rendering. Rack instrumentation is automatically
enabled when using Sinatra instrumentation.

The source for this instrumentation is located [here](https://github.com/signalfx/ruby-sinatra-instrumentation).

### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i sinatra
```

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Sinatra)
end
```

## Configuring the Logger

The logger, based on the [Ruby Logger](https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html), can be configured by setting the following environment variables:

| Environmental Variable Name   | Description           |  Default             |
|:------------------------------|:----------------------|:-------------------- |
| `SIGNALFX_LOG_PATH`           | The path to the desired file where the instrumentation logs will be written. Besides customized paths, output options also include `STDOUT` and `STDERR`.| `/var/log/signalfx/signalfx-ruby-tracing.log` |
| `SIGNALFX_LOG_SHIFT_AGE`      | The desired number of old log files to keep, or frequency of rotation. Options include: `daily`, `weekly` or `monthly`)  | `0`    |
| `SIGNALFX_LOG_SHIFT_SIZE`     | The desired maximum size of log files (this only applies when. A new one would be created when the maximum is reached. | `1048576` (1 MB)  |
| `SIGNALFX_LOG_LEVEL`          | The severity criteria for recording logs (from least to most severe). Options: `debug`, `info`, `warn`, `error`, `fatal`, `unknown`  | `warn` |

More information regarding the logging configuration may be found [here](https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html).

**NB**: 
- If the default path for `SIGNALFX_LOG_PATH` (that is, `/var/log/signalfx/signalfx-ruby-tracing.log`) is to be used, then please create the directory and or file (if necessary) and grant the relevant access permissions to the instrumentation user process.
If there are permission issues, the instrumentation will default to logging to the standard error (STDERR) handle, until the path is provided to which logs can be written without any access issues.
