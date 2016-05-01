require File.expand_path('../lib/motion-markdown-it-math/version.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'motion-markdown-it-math'
  gem.version       = MotionMarkdownItMath::VERSION
  gem.authors       = ["Chris Hunt"]
  gem.email         = 'chrahunt@gmail.com'
  gem.summary       = "Plugin for motion-markdown-it"
  gem.description   = "Plugin for use with motion-markdown-it"
  gem.homepage      = 'https://github.com/chrahunt/motion-markdown-it-math'
  gem.licenses      = ['MIT']

  gem.files         = Dir.glob('lib/**/*.rb')
  gem.files        << 'README.md'
  gem.test_files    = Dir["spec/**/*.rb"]

  gem.require_paths = ["lib"]

  gem.add_dependency 'motion-markdown-it', '~> 4.0'
end
