# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'pi-helpers'
  spec.version       = '0.1.7'
  spec.licenses      = ['MIT']
  spec.authors       = ['Kevin Rutherford']
  spec.email         = ['kevin@rutherford-software.com']

  spec.summary       = %q{A set of opinionated helpers for Rack and rspec}
  spec.description   = %q{A set of opinionated helpers for Rack and rspec}
  spec.homepage      = "https://github.com/kevinrutherford/pi-helpers"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'es-http-client', '~> 0.2'
  spec.add_runtime_dependency 'es-readmodel', '~> 1'
  spec.add_runtime_dependency 'faraday', '~> 0.15'
  spec.add_runtime_dependency 'json', '~> 2.1'
  spec.add_runtime_dependency 'jwt', '~> 2.1'
  spec.add_runtime_dependency 'rack', '~> 2.0'
  spec.add_runtime_dependency 'rspec', '~> 3.7'
  spec.add_runtime_dependency 'uuidtools', '~> 2'

  spec.add_development_dependency 'simplecov'

end

