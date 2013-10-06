# -*- encoding: utf-8 -*-
$:.unshift(File.expand_path('../lib', __FILE__))
require 'proxyreverse/version'

Gem::Specification.new do |s|
  s.name        = 'proxyreverse'
  s.version     = ProxyReverse::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Andy Thompson']
  s.email       = ['me@andytson.com']
  s.homepage    = 'http://github.com/andytson/proxyreverse'
  s.summary     = 'Reverse proxy your local web-server'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  s.add_dependency('em-proxy', '~> 0.1.8')
  s.add_dependency('http_parser.rb', '~> 0.5.3')
  s.add_development_dependency('bundler', '>= 1.0.10')
  s.add_development_dependency('rake', '>= 0.8.7')
end
