lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
File.read('lib/pg/connection/general_log/version.rb') =~ /.*VERSION\s*=\s*['"](.*?)['"]\s.*/
version = Regexp.last_match(1)

Gem::Specification.new do |spec|
  spec.name          = 'pg-connection-general_log'
  spec.version       = version
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
end
