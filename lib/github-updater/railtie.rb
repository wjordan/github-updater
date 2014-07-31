module GithubUpdater
  class Railtie < Rails::Railtie
    initializer 'github-updater.insert_middleware' do |app|
      app.config.middleware.use 'GithubUpdater::Middleware'
    end
  end
end
