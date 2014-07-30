require 'sinatra/base'
require 'json'

class GithubUpdater < Sinatra::Base
  post '/github-receive' do
    push = JSON.parse(request.body.read)
    puts "I got some JSON: #{push.inspect}"
  end
end
