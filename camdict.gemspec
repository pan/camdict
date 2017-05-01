# frozen_string_literal: true
Gem::Specification.new do |s|
  s.name = 'camdict'
  s.version = '2.0.0'
  s.date = '2017-05-01'
  s.authors = ['Pan Gaoyong', "\u{6f58}\u{9ad8}\u{52c7}"]
  s.email = 'pan.gaoyong@gmail.com'
  s.summary = 'online Cambridge dictionary client'
  s.description = 'Get definitions, pronunciation and example sentences of' \
    ' a word or phrase from the online Cambridge dictionaries.'
  s.files = ['license', 'Rakefile', 'README.md', 'lib/camdict.rb'] +
            Dir['lib/camdict/*']
  s.test_files = Dir['test/*']
  s.homepage = 'https://github.com/pan/camdict'
  s.license = 'MIT'
  s.add_runtime_dependency 'nokogiri', '>= 1.6.2'
  s.add_development_dependency 'minitest', '>= 5.8.3'
  s.required_ruby_version = '>= 2.3.0'
end
