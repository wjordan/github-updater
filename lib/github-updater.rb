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
        verify_signature(payload_body)
        payload = JSON.parse(payload_body)
        halt 500 unless current_repo?(payload['repository']['html_url'])
        halt 500 unless current_branch?(payload['ref'])
        (GithubUpdater::instance_variable_get(:@webhooks) || []).each do |block|
          block.call(payload)
        end
        status 200
      rescue => e
        puts "error:#{e}"
        halt 500
      end
    end

    def verify_signature(payload_body)
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['WEBHOOK_SECRET_TOKEN'], payload_body)
      return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
    end

    def current_repo?(url)
      git_url = `git ls-remote --get-url`.strip.gsub(/git@github.com:/, 'https://github.com/')
      url == git_url
    end

    def current_branch?(branch)
      git_branch = `git symbolic-ref HEAD`.strip
      git_branch == branch
    end

  end

  def self.webhook(&block)
    (@webhooks ||= []) << block
  end
end

require 'github-updater/railtie' if defined? Rails
