$:.push File.expand_path('../lib', __FILE__)

require 'dradis/plugins/slack/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.platform    = Gem::Platform::RUBY
  spec.name        = 'dradis-slack'
  spec.version     = Dradis::Plugins::Slack::VERSION::STRING
  spec.summary     = 'This integration connects Dradis with your team\'s Slack.'
  spec.description = 'Send Dradis Framework notifications into your Slack channel.'

  spec.license = 'GPL-2'

  spec.authors = ['Daniel Martin']
  spec.email = ['etd@nomejortu.com']
  spec.homepage = 'http://dradisframework.org'

  spec.files = `git ls-files`.split($\)
  spec.executables = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})

  spec.add_dependency 'dradis-plugins', '~> 3.0'
  spec.add_dependency 'slack-notifier'
end
