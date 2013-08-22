# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "error_inbox/version"

Gem::Specification.new do |spec|
  spec.name          = "errorinbox"
  spec.version       = ErrorInbox::VERSION
  spec.authors       = ["Rafael Souza"]
  spec.email         = ["me@rafaelss.com"]
  spec.description   = %q{Send exceptions to errorinbox.com}
  spec.summary       = %q{Capture and send all exceptions raised by your app to errorinbox.com}
  spec.homepage      = "http://github.com/rafaelss/errorinbox"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
