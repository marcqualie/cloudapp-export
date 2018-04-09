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
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dotenv", "2.2.1"
  spec.add_dependency "net-http-digest_auth", "1.4.1"
  spec.add_dependency "thor", "0.20.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rubocop", "~> 0.54.0"
  spec.add_development_dependency "minitest", "~> 5.11"
end
