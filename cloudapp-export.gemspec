require_relative "lib/cloudapp_export/version"

Gem::Specification.new do |spec|
  spec.name          = "cloudapp-export"
  spec.version       = CloudappExport::VERSION
  spec.authors       = ["Marc Qualie"]
  spec.email         = ["marc@marcqualie.com"]

  spec.summary       = "A quick way to export all the data you have stored in CloudApp"
  spec.homepage      = "https://github.com/marcqualie/cloudapp-export"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.3"

  spec.add_dependency "dotenv", "2.5.0"
  spec.add_dependency "net-http-digest_auth", "1.4.1"
  spec.add_dependency "thor", "0.20.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "minitest", "~> 5.11"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rubocop", "~> 0.59.2"
  spec.add_development_dependency "simplecov", "~> 0.16.1"
end
