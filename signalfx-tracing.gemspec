lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "signalfx/tracing/version"

Gem::Specification.new do |spec|
  spec.name          = "signalfx-tracing"
  spec.version       = Signalfx::Tracing::VERSION
  spec.authors       = ["SignalFx, Inc."]
  spec.email         = ["info@signalfx.com"]

  spec.summary       = %q{Auto-instrumentation framework for Ruby}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/signalfx/signalfx-ruby-tracing"
  spec.license       = "Apache-2.0"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"

  # TODO pin versions once consistent across all dependencies
  spec.add_dependency "opentracing", "> 0.3.0"
  spec.add_dependency "jaeger-client", "~> 1.0.0"

  # We are no longer setting all available instrumentations as dependencies.
  # Manual installation via bootstrapper or gem.deps.rb is now required.
  # `sfx-rb-trace-bootstrap -i sinatra,redis,etc.`
  # `gem install -g`

  # stdlib instrumentations
  spec.add_dependency "nethttp-instrumentation", "~> 0.1.2"

  spec.add_development_dependency 'signalfx-faraday-instrumentation~> 0.1.1', '~> 0'
end
