require 'sinatra/base'
require 'json'

module GithubUpdater
  class Middleware < Sinatra::Base
    set :raise_errors, false
    set :show_exceptions, false

    post '/github-webhook' do
      begin
        request.body.rewind
        payload_body = request.body.read
        halt 500 unless verify_signature(payload_body)
        payload = JSON.parse(payload_body)
        halt 500 unless current_repo == payload['repository']['html_url'] && current_branch == payload['ref']
        (GithubUpdater::instance_variable_get(:@webhooks) || []).each do |block|
          block.call(payload)
        end
        status 200
      rescue => e
        puts "Error:#{e}"
        halt 500
      end
    end

    def verify_signature(payload_body)
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['WEBHOOK_SECRET_TOKEN'], payload_body)
      Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
    end

    def current_repo
      `git ls-remote --get-url`.strip.gsub(/git@github.com:/, 'https://github.com/')
    end

    def current_branch
      `git symbolic-ref HEAD`.strip
    end

  end

  def self.webhook(&block)
    (@webhooks ||= []) << block
  end
end

require 'github-updater/railtie' if defined? Rails::Railtie
