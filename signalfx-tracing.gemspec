lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "signalfx/tracing/version"

Gem::Specification.new do |spec|
  spec.name          = "signalfx-tracing"
  spec.version       = Signalfx::Tracing::VERSION
  spec.authors       = ["Ashwin Chandrasekar"]
  spec.email         = ["achandrasekar@signalfx.com"]

  spec.summary       = %q{Auto-instrumentation framework for Ruby}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/signalfx/signalfx-ruby-tracing"
  spec.license       = "Apache 2.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"

  # TODO pin versions once consistent across all dependencies
  spec.add_dependency "opentracing", "> 0.3.0"
  spec.add_dependency "jaeger-client", "~> 0.6.1"
  spec.add_dependency "sinatra-tracer", "~> 0.1.0"
  spec.add_dependency "faraday-tracer", "~> 0.7.0"
  spec.add_dependency "net-http-tracer", "~> 0.1.0"
  spec.add_dependency "rails-tracer", "~> 0.5.0"
  spec.add_dependency "restclient-instrumentation", "~> 0.1"
  spec.add_dependency "mongodb-instrumentation", "~> 0.1"
  spec.add_dependency "elasticsearch-tracer", "~> 1.0"

  spec.add_dependency "rack-tracer", "~> 0.3"
  spec.add_dependency "activerecord-opentracing", "~> 0.2.1"
end
