# -*- encoding: utf-8 -*-
require File.expand_path('../lib/termup/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Kenn Ejima"]
  gem.email         = ["kenn.ejima@gmail.com"]
  gem.description   = %q{Setup terminal tabs with preset commands for your projects}
  gem.summary       = %q{Setup terminal tabs with preset commands for your projects}
  gem.homepage      = "https://github.com/kenn/termup"

  gem.files         = `git ls-files`.split($\).reject{|f| f =~ /^images/ } # Exclude images
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "termup"
  gem.require_paths = ["lib"]
  gem.version       = Termup::VERSION

  gem.add_runtime_dependency 'rb-appscript', '~> 0.6.1'
  gem.add_runtime_dependency 'thor', '~> 0.16.0'
end
