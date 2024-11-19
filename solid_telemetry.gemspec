require_relative "lib/solid_telemetry/version"

Gem::Specification.new do |spec|
  spec.name = "solid_telemetry"
  spec.version = SolidTelemetry::VERSION
  spec.authors = ["Patricio Mac Adden"]
  spec.email = ["patriciomacadden@gmail.com"]
  spec.homepage = "https://github.com/sinaptia/solid_telemetry"
  spec.summary = "Database-backed OpenTelemetry."
  spec.description = "Database-backed OpenTelemetry."

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "acts_as_tree"
  spec.add_dependency "groupdate"
  spec.add_dependency "importmap-rails", "~> 1.2"
  spec.add_dependency "kaminari"
  spec.add_dependency "opentelemetry-sdk", ">= 1.5"
  spec.add_dependency "opentelemetry-metrics-sdk", ">= 0.2"
  spec.add_dependency "opentelemetry-instrumentation-all", ">= 0.66"
  spec.add_dependency "rails", ">= 7.2"
  spec.add_dependency "stimulus-rails"
  spec.add_dependency "tailwindcss-rails", "~> 3.0"
  spec.add_dependency "turbo-rails"
end
