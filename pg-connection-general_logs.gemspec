lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pg/connection/general_log/version'

Gem::Specification.new do |spec|
  spec.name          = 'pg-connection-general_log'
  spec.version       = PG::Connection::GeneralLog::VERSION
  spec.authors       = ['abcang']
  spec.email         = ['abcang1015@gmail.com']

  spec.summary       = 'Simple stocker general log for pg gem.'
  spec.description   = 'Simple stocker general log for pg gem.'
  spec.homepage      = 'https://github.com/abcang/pg-connection-general_log'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'pg'
  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 12.2'
  spec.add_development_dependency 'rgot'
  spec.add_development_dependency 'sinatra'
end
