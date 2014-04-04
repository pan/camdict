Gem::Specification.new do |s|
  s.name = 'camdict'
  s.version = '1.0.1'
  s.date = '2014-04-04'
  s.authors = ["Pan Gaoyong", "\u{6f58}\u{9ad8}\u{52c7}"]
  s.email = 'pan.gaoyong@gmail.com'
  s.summary = 'online Cambridge dictionary client'
  s.description = "Get definitions, pronunciation and example sentences of" +
    " a word or phrase from the online Cambridge dictionaries." 
  s.files = ["license", "Rakefile", "README.md", "lib/camdict.rb"] + 
    Dir["lib/camdict/*"] + Dir["test/*"]
  s.homepage = 'https://github.com/pan/camdict'
  s.license = 'MIT'
  s.add_runtime_dependency "nokogiri"
  s.required_ruby_version = '>= 1.9.3' # also required by nokogiri 
end
