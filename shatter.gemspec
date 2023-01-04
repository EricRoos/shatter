# frozen_string_literal: true

require_relative "lib/shatter/version"

Gem::Specification.new do |spec|
  spec.name = "shatter"
  spec.version = Shatter::VERSION
  spec.authors = ["Eric Roos"]
  spec.email = ["ericroos@hey.com"]

  spec.summary = "Write a short summary, because RubyGems requires one."
  spec.description = "Write a longer description or delete this line."
  spec.homepage = "https://github.com/EricRoos/shatter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/EricRoos/shatter"
  spec.metadata["changelog_uri"] = "https://github.com/EricRoos/shatter/tree/master/CHANGELOG"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "rack", "~> 3.0"
  spec.add_dependency "rackup", "~> 0.2.3"
  spec.add_dependency "concurrent-ruby", "~> 1.1"
  spec.add_dependency "pg", "~> 1.4"
  spec.add_dependency "zk", "~> 1.10"
  spec.add_dependency "puma", "~> 6.0"
  spec.add_dependency "thor", "~> 1.2.1"
  spec.add_dependency "erb", "~> 2.2.0"
  # spec.add_dependency "zookeeper", "~>1.5.4", github: 'EricRoos/zookeeper'

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "rubocop-rake"
  spec.add_development_dependency "rubocop-rspec"
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
