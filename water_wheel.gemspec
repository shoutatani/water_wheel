# frozen_string_literal: true

require_relative "lib/water_wheel/version"

Gem::Specification.new do |spec|
  spec.name = "water_wheel"
  spec.version = WaterWheel::VERSION
  spec.authors = ["shoutatani"]
  spec.email = ["shoutatani.git@gmail.com"]

  spec.summary = "Backup local files or directories to S3"
  spec.description = "Backup local files or directories to S3. After initial upload, only updated items will be synced."
  spec.homepage = "https://github.com/shoutatani/water_wheel"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/shoutatani/water_wheel"
  spec.metadata["changelog_uri"] = "https://github.com/shoutatani/water_wheel/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "fog-aws", "~> 3.0"
  spec.add_dependency "retriable", "~> 3.1"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
