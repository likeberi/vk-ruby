# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'vk_api/version'

Gem::Specification.new do |s|
  s.name        = 'vk_api'
  s.version     = VkApi::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Nikolay Karev', 'Nick Recobra']
  s.email       = ['oruenu@gmail.com']
  s.homepage    = 'https://github.com/oruen/vk_api'
  s.summary     = 'Гем для общения с Open API сайта ВКонтакте'
  s.description =
    'Гем для общения с Open API сайта ВКонтакте без использования пользовательских сессий.'

  s.rubyforge_project = 'vk_api'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency('activesupport')
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.7.0', '>= 3.7.0'
  s.add_development_dependency 'rubocop', '~> 0.58.2'
  s.add_development_dependency 'webmock', '~> 2.3.2', '>= 2.3.2'
end
