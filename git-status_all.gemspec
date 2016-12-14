# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git/status_all/version'

Gem::Specification.new do |spec|
  spec.name          = "git-status_all"
  spec.version       = Git::StatusAll::VERSION
  spec.authors       = ["Nathan Reed"]
  spec.email         = ["reednj@gmail.com"]

  spec.summary       = %q{get the status of all git repositories in a directory}
  spec.homepage      = "https://github.com/reednj/git-status_all"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.required_ruby_version = '>=1.9.3'
  spec.add_dependency  'colorize'
  spec.add_dependency  'trollop'
  spec.add_dependency  'git', "~> 1.3"
end
