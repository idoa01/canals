$:.push File.expand_path('../lib', __FILE__)
require 'canals/version'

Gem::Specification.new do |s|
  s.name                  = "canals"
  s.version               = Canals::VERSION
  s.platform              = Gem::Platform::RUBY

  s.summary               = "Eases the process of creating and managing SSH tunnels"
  s.description           = "A console utility to help build ssh tunnels and keep them up"
  s.authors               = ["Ido Abramovich"]
  s.email                 = "canals.sf17@abramovich.info"
  s.homepage              = 'http://github.com/idoa01/canals'

  s.required_ruby_version = '>= 2.2.0'
  s.rubyforge_project     = "canals"
  s.files                 = `git ls-files`.split($/)
  s.test_files            = `git ls-files -- {test,spec,features}/*`.split($/)
  s.executables           = `git ls-files -- bin/*`.split($/).map{ |f| File.basename(f) }
  s.require_path          = "lib"
  s.license               = "MIT"

  s.add_dependency        'thor', '~> 0.19.1'
  s.add_dependency        'terminal-table', '~> 1.5'

  s.add_development_dependency 'rspec', '~> 3.4'
end
