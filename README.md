# SignalFx Tracing Library for Ruby

The SignalFx Tracing Library for Ruby helps you instrument Ruby applications
with the OpenTracing API to capture and report distributed traces to SignalFx.

The library consists of an auto-instrumentor that works with OpenTracing
community-provided instrumentations, and provides a bootstrap utility to help
install instrumentations. It also configures and uses a
[Jaeger tracer](https://github.com/salemove/jaeger-client-ruby) to send trace
data to SignalFx.

## Requirements and supported software

Here are the requirements and supported software for the library.

### Supported runtimes

- MRI Ruby (CRuby) 2.0+

### Supported servers

- Puma >= 3.0.0
- Passenger >= 5.0.25

### Supported libraries

| Library                         | Instrumentation name                   | Versions Supported |
| ------------------------------- | -------------------------------------- | ------------------ |
| [ActiveRecord](#active-record)  | activerecord-opentracing               | ~> 5.0             |
| [Elasticsearch](#elasticsearch) | signalfx-elasticsearch-instrumentation | >= 6.0.2           |
| [Faraday](#faraday)             | signalfx-faraday-instrumentation       | >= 0.9.0           |
| [Grape](#grape)                 | grape-instrumentation                  | >= 0.2.0           |
| [Mongo](#mongo)                 | mongodb-instrumentation                | >= 2.1.0           |
| [Mysql2](#mysql2)               | mysql2-instrumentation                 | >= 0.4.0           |
| [Net::HTTP](#nethttp)           | nethttp-instrumentation                | Ruby >= 2.0        |
| [Pg](#pg)                       | pg-instrumentation                     | >= 0.18.0          |
| [Rack](#rack)                   | sfx-rack-tracer                        | >= 0.10.0          |
| [Rails](#rails)                 | rails-instrumentation                  | >= 3.0.0           |
| [Redis](#redis)                 | redis-instrumentation                  | >= 4.0.0           |
| [RestClient](#restclient)       | restclient-instrumentation             | >= 1.5.0           |
| [Sequel](#sequel)               | sequel-instrumentation                 | >= 3.47.0          |
| [Sidekiq](#sidekiq)             | sfx-sidekiq-opentracing                | >= 0.7.0           |
| [Sinatra](#sinatra)             | sinatra-instrumentation                | >= 1.0.0           |

Instrumentation for routes using Puma or Passenger is provided through
Rack. If you use a framework that builds on top of Rack, such as Rails or
Sinatra, install the `sfx-rack-tracer` instrumentation with your dependency manager
or with the bootstrap utility. In these cases, the routes through the web
server are automatically traced.

## Install the SignalFx Tracing Library for Ruby

Follow these steps to install the tracing library. You can either use the
bootstrap utility to install the tracing library and its dependencies or
manually install everything. 

The bootstrap utility updates your Gemfile and installs the required
dependencies for you. For information about the bootstrap utility, see the
[sfx-rb-trace-bootstrap](bin/sfx-rb-trace-bootstrap) file.

The steps assume you have RubyGems and Bundler.

### Install the library with the bootstrap utility

1. Install the tracing library:
   ```bash
   $ gem install signalfx-tracing
   ```
2. View the list of instrumentations you can install with the bootstrap utility:
   ```bash
   $ sfx-rb-trace-bootstrap --list
   ```
3. Use the bootstrap utility to install applicable instrumentations for your
   application. For example, this is how you add Rails and Redis:
   ```bash
   $ sfx-rb-trace-bootstrap --install-deps rails,redis
   ```
   For information about instrumentation names, see supported libraries and their
   current versions in `gem.deps.rb`. If you configure Rails instrumentation, it
   also configures Active Record instrumentation, so you don't need to instrument both.

### Manually install the library

1. Download the [latest release](https://github.com/signalfx/signalfx-ruby-tracing/releases/latest) of the tracing library.
2. Add `signalfx-tracing` to your application's Gemfile:
   ```bash
   $ gem 'signalfx-tracing'
   ```
3. Add each applicable instrumentation to your application's Gemfile. For
   example, this is how you add Rails and Redis:
   ```bash
   $ gem 'rails-instrumentation'
   $ gem 'redis-instrumentation'
   ```
   For information about instrumentation names, see supported libraries and their
   current versions in `gem.deps.rb`. If you configure Rails instrumentation, it
   also configures Active Record instrumentation, so you don't need to instrument both.
4. Install the gems for the tracing library and instrumentations:
   ```bash
   $ bundle install
   ```

## Configure instrumentation for a Ruby application

Configure the instrumentation anywhere in the setup portion of your code or
before importing and using any libraries that need to be traced.

For example, with Rails, configure instrumentation in `config/initializer/tracing.rb`.

You can configure instrumentation automatically or manually. Manual
instrumentation is convenient when you want to trace only some libraries.

### Set configuration values

If the default configuration values don't apply for your environment, override them before running the process you instrument.

| `configure` parameter | Environment variable  | Default                          | Notes |
| ------------------- | ---------------------------------  | -------------------------------- | ----- |
| tracer              | N/A                                | `nil`                            | The OpenTracing global tracer. |
| ingest_url          | SIGNALFX_ENDPOINT_URL              | `http://localhost:9080/v1/trace` | The endpoint the tracer sends spans to. Send spans to a Smart Agent, OpenTelemetry Collector, or a SignalFx ingest endpoint. |
| service_name        | SIGNALFX_SERVICE_NAME              | `signalfx-ruby-tracing`          | The name to identify the service in SignalFx. |
| access_token        | SIGNALFX_ACCESS_TOKEN              | `''`                             | The SignalFx organization access token. |
| span_tags           | SIGNALFX_SPAN_TAGS                 | `nil`                            | Comma-separated list of tags included in every reported span. For example, "key1:val1,key2:val2". Use only string values for tags.|
| N/A                 | SIGNALFX_RECORDED_VALUE_MAX_LENGTH | `1200`                           | Maximum length an attribute value can have. Values longer than this are truncated. |


### Automatically instrument code:

Configure the auto-instrumentor to check for modules defined in the code and
instrument them if available:

```ruby
require 'signalfx/tracing'

SignalFx::Tracing::Instrumenter.configure(auto_instrument:true)
```

### Manually specify which libraries to instrument

Specify which libraries to instrument:

```ruby
require 'signalfx/tracing'

SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(<:myLibName>)
    ...
end
```

## Usage information for each library

Here's information about instrumenting each supported library.

### Active Record

This instrumentation creates spans for each Active Record query using the Active
Support notifications framework. If you configure Rails instrumentation, it also configures Active Record instrumentation, so you don't need to instrument both.

The source for this instrumentation is located
[here](https://github.com/salemove/ruby-activerecord-opentracing).

#### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i activerecord
```

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:ActiveRecord)
end
```

### Elasticsearch

Elasticsearch queries through the Ruby client are traced using a wrapper around
the transport.

The forked source for the instrumentation is located
[here](https://github.com/signalfx/ruby-elasticsearch-tracer).

#### Usage

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

### Faraday

Faraday HTTP client instrumentation automatically creates spans for outgoing
requests. If the remote service has instrumentation that is aware of Rack,
those spans will be automatically nested with Faraday's spans.

The source for this instrumentation is located
[here](https://github.com/opentracing-contrib/ruby-faraday-tracer).

#### Usage

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

### Grape

This instrumentation subscribes to ActiveSupport notifications emitted by the
Grape API. It patches `Grape::API` to automatically insert the `Rack::Tracer`
middleware and trace requests.

The source for this instrumentation is located
[here](https://github.com/signalfx/ruby-grape-instrumentation)

#### Usage

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
- `parent_span`: parent span to group spans or block that returns a span.
  Default: `nil`
- `disable_patching`: disable patching if managing the middleware stack
  manually. Default: `false`

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

### Mongo

Mongo driver instrumentation traces queries performed through the Ruby Mongodb
driver.

The source for this instrumentation is located
[here](https://github.com/signalfx/ruby-mongodb-instrumentation)

#### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i mongodb
```

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:MongoDB)
end
```

### Mysql2

Mysql2 instrumentation traces all queries performed with the Mysql2 client.

The source for this instrumentation is located
[here](https://github.com/signalfx/ruby-mysql2-instrumentation)

#### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i mysql2
```

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Mysql2)
end
```

### Net::HTTP

This automatically traces all requests using Net::HTTP.

The source for this instrumentation is located
[here](https://github.com/signalfx/ruby-net-http-instrumentation).

#### Usage

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:NetHttp, tracer: tracer)
end
```

An optional `tracer` named argument can be provided to use a custom tracer.
It will default to `OpenTracing.global_tracer` if not provided.

### Pg

Pg instrumentation traces all queries performed with the pg client.

The source for this instrumentation is located
[here](https://github.com/signalfx/ruby-pg-instrumentation)

#### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i pg
```

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:pg)
end
```
### Rack

Rack spans are created using the `sfx-rack-tracer` gem. This is enabled
automatically for other frameworks that are built on top of Rack, but it can
also be separately enabled.

The source for this instrumentation is located
[here](https://github.com/signalfx/ruby-rack-tracer).

#### Usage

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

### Rails

Rails applications can be traced using the notifications provided by ActiveSupport.
It will use `sfx-rack-tracer` to trace by requests.

The forked source for this instrumentation is located
[here](https://github.com/signalfx/ruby-rails-instrumentation).

#### Usage

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

### Redis

This instrumentation traces commands performed using the
[Redis client](https://github.com/redis/redis-rb).

The source for this instrumentation is located
[here](https://github.com/signalfx/ruby-redis-instrumentation).

#### Usage

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

### RestClient

RestClient requests can be patched to automatically be wrapped in a span. It
will also inject the span context so remote services can extract it.

The source for this instrumentation is located
[here](https://github.com/signalfx/ruby-restclient-instrumentation).

#### Usage

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

### Sequel

Sequel instrumentation adds extensions to the Database and Dataset to trace
queries.

The source for this instrumentation is located
[here](https://github.com/signalfx/ruby-sequel-instrumentation).

#### Usage

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

### Sidekiq

Sidekiq instrumentation traces worker job submissions and execution via
[Sidekiq middleware](https://github.com/mperham/sidekiq/wiki/Middleware).
The instrumenter registers both client and server middleware that use job
metadata to represent all job submissions and their invocations. Trace
context propagation adds to this job metadata to unifiy distributed client
and server requests and processing.

The source for this instrumentation is located
[here](https://github.com/signalfx/ruby-sidekiq-tracer).

#### Usage

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
- `propagate`: Optional boolean to enable/disable trace context injection via
  job metadata
  - Default: `true`


### Sinatra

Sinatra instrumentation traces requests and template rendering. The instrumenter
registers a Sinatra extension that uses `sfx-rack-tracer` to trace requests and
monkey-patches to trace view rendering. Rack instrumentation is automatically
enabled when using Sinatra instrumentation.

The source for this instrumentation is located
[here](https://github.com/signalfx/ruby-sinatra-instrumentation).

#### Usage

```bash
$ # install the instrumentation if not done previously
$ sfx-rb-trace-bootstrap -i sinatra
```

```ruby
SignalFx::Tracing::Instrumenter.configure do |p|
    p.instrument(:Sinatra)
end
```

## Configure the logger

The logger, based on the [Ruby Logger](https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html),
can be configured by setting the following environment variables:

| Environmental Variable Name   | Description           |  Default             |
|:------------------------------|:----------------------|:-------------------- |
| `SIGNALFX_LOG_PATH`           | The path to the desired file where the instrumentation logs will be written. Besides customized paths, output options also include `STDOUT` and `STDERR`.| `/var/log/signalfx/signalfx-ruby-tracing.log` |
| `SIGNALFX_LOG_SHIFT_AGE`      | The desired number of old log files to keep, or frequency of rotation. Options include: `daily`, `weekly` or `monthly`)  | `0`    |
| `SIGNALFX_LOG_SHIFT_SIZE`     | The desired maximum size of log files (this only applies when. A new one would be created when the maximum is reached. | `1048576` (1 MB)  |
| `SIGNALFX_LOG_LEVEL`          | The severity criteria for recording logs (from least to most severe). Options: `debug`, `info`, `warn`, `error`, `fatal`, `unknown`  | `warn` |

More information regarding the logging configuration may be found
[here](https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html).

**NB**: 
- If the default path for `SIGNALFX_LOG_PATH` (that is, `/var/log/signalfx/signalfx-ruby-tracing.log`)
  is to be used, then please create the directory and or file (if necessary)
  and grant the relevant access permissions to the instrumentation user process.
  If there are permission issues, the instrumentation will default to logging to
  the standard error (STDERR) handle, until the path is provided to which logs
  can be written without any access issues.
