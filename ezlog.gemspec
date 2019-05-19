lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ezlog/version"

Gem::Specification.new do |spec|
  spec.name          = "ezlog"
  spec.version       = Ezlog::VERSION
  spec.authors       = ["Zoltan Ormandi"]
  spec.email         = ["zoltan.ormandi@emarsys.com"]
  spec.summary       = "A zero-configuration logging solution for projects using Sidekiq, Rails, Sequel, etc."
  spec.homepage      = "https://github.com/emartech/ezlog"
  spec.license       = "MIT"

  spec.metadata      = {
    "changelog_uri" => "https://github.com/emartech/ezlog/blob/master/CHANGELOG.md",
  }

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "logging", "~> 2.0"
  spec.add_dependency "multi_json"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sidekiq", "~> 5.0"
end
