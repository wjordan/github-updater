Gem::Specification.new do |s|
  s.name        = 'github-updater'
  s.version     = '0.0.0'
  s.authors     = ['wjordan']
  s.summary     = 'Simple github updater'
  s.files       = %w(lib/github-updater.rb lib/github-updater/railtie.rb)
  s.license       = 'MIT'
  s.add_runtime_dependency 'sinatra'
end
