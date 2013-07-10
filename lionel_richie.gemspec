# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lionel/version'

Gem::Specification.new do |spec|
  spec.name          = "lionel_richie"
  spec.version       = Lionel::VERSION
  spec.authors       = ["Ross Kaffenberger"]
  spec.email         = ["rosskaff@gmail.com"]
  spec.description   = %q{Export Trello to Google Docs}
  spec.summary       = %q{Export Trello to Google Docs}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.bindir = 'bin'
  spec.executables = %w(lionel)

  spec.add_dependency "ruby-trello"
  spec.add_dependency "google_drive"
  spec.add_dependency "yajl-ruby"
  spec.add_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "launchy"
end
