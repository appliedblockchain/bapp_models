# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bapp_models/version'

Gem::Specification.new do |spec|
  spec.name          = "bapp_models"
  spec.version       = BAppModels::VERSION
  spec.authors       = ["makevoid"]
  spec.email         = ["makevoid@gmail.com"]

  spec.summary       = %q{BAppModels contains an Ethereum model definition library and a KeyValue API}
  spec.description   = %q{BAppModels contains an Ethereum model definition library and a KeyValue API for accessing ethereum easily from your app. BAppModels depends on appliedblockchain/ethereum RPC library.}
  spec.homepage      = "https://github.com/appliedblockchain"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # ffi
  spec.add_runtime_dependency "ffi",   "~> 1.9.18"

  # sha3
  spec.add_runtime_dependency "sha3",   "~> 1.0.1"

  # keychain
  spec.add_runtime_dependency "bitcoin-ruby",   "= 0.0.10"

  # privacy
  # TODO: remove dependency RLP (easy w/o vendorizing it)
  spec.add_runtime_dependency "rlp", "~> 0.7.3"
  # spec.add_runtime_dependency "",   ""

  # models
  spec.add_runtime_dependency "virtus",   "~> 1.0"   # .5
  spec.add_runtime_dependency "redis",    "~> 3.3"   # .3
  spec.add_runtime_dependency "oj",       "~> 3.0"   # .7
  spec.add_runtime_dependency "inflecto", "=  0.0.2"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
