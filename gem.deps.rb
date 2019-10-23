group :instrumentations do
  gem 'activerecord-opentracing', '~> 0.2.1'
  gem 'grape-instrumentation', "~> 0.1.0"
  gem 'mongodb-instrumentation', '~> 0.1.1'
  gem 'mysql2-instrumentation', '~> 0.2.1'
  gem 'nethttp-instrumentation', '~> 0.1.2'
  gem 'rack-tracer', git: 'git://github.com/signalfx/ruby-rack-tracer.git', branch: 'sfx_release'
  gem 'rails-instrumentation', '0.1.3'
  gem 'redis-instrumentation', '~> 0.1.1'
  gem 'restclient-instrumentation', '~> 0.1.1'
  gem 'sequel-instrumentation', '~> 0.1.0'
  gem 'signalfx-elasticsearch-instrumentation', '~> 0.1.0'
  gem 'signalfx-faraday-instrumentation', '~> 0.1.1'
  gem 'sinatra-instrumentation', '~> 0.1.2'
end