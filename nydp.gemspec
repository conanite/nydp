# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nydp/version'

Gem::Specification.new do |spec|
  spec.name          = "nydp"
  spec.version       = Nydp::VERSION
  spec.authors       = ["Conan Dalton"]
  spec.email         = ["conan@conandalton.net"]
  spec.description   = %q{ NYDP : Not Your Daddy's Parentheses (a kind of Lisp)                 }
  spec.summary       = %q{ A civilised yet somewhat dangerous kind of Lisp for a new generation }
  spec.homepage      = "http://github.com/conanite/nydp"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "irb"
  spec.add_development_dependency "rake", "~> 13"
  spec.add_development_dependency 'rspec' #, '~> 3.1'
end
