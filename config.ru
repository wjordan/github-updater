require 'rubygems'
require 'bundler'
Bundler.require
require './lib/github-updater'
ENV['WEBHOOK_SECRET_TOKEN']= '5779f4c'
GithubUpdater.webhook do |payload|
  puts "Payload: #{payload.inspect}"
end
run GithubUpdater::Middleware
