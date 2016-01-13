$:.push File.expand_path('../lib', __FILE__)
require 'canals/version'

Gem::Specification.new do |s|
  s.name                  = "canals"
  s.version               = Canals::VERSION
  s.platform              = Gem::Platform::RUBY
  s.summary               = "Help manage ssh tunnels"
  s.description           = "A console utility to help raise ssh tunnels and keep them up"
  s.author                = ["Ido"]
  s.homepage              = 'http://github.com/idoa01/canals'
  s.required_ruby_version = '>= 2.2.0'
  s.rubyforge_project     = "canals"
  s.files                 = `git ls-files`.split($/)
  s.test_files            = `git ls-files -- {test,spec,features}/*`.split($/)
  s.executables           = `git ls-files -- bin/*`.split($/).map{ |f| File.basename(f) }
  s.require_path          = ["lib"]
end
