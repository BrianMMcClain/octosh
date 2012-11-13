# -*- encoding: utf-8 -*-
require File.expand_path('../lib/octosh/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Brian McClain"]
  gem.email         = ["brianmmcclain@gmail.com"]
  gem.description   = %q{Octosh}
  gem.summary       = gem.summary
  gem.homepage      = "https://github.com/BrianMMcClain/octosh"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cfcm"
  gem.require_paths = ["lib"]
  gem.version       = Octosh::VERSION
end