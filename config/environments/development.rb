Meleze::Application.configure do
  #config.assets.compile = true
  #config.assets.precompile += ['application.js']
  #config.assets.precompile << Proc.new { |path|
    #if path =~ /\.(css|js)\z/
      #full_path = Rails.application.assets.resolve(path).to_path
      #app_assets_path = [ Rails.root.join('app', 'assets').to_path, Rails.root.join('vendor', 'assets').to_path ]
      #if app_assets_path.any? { |asp| full_path.starts_with? asp } #full_path.starts_with? app_assets_path
        #puts "including asset: " + full_path
        #true
      #else
        #puts "excluding asset: " + full_path
        #false
      #end
    #else
      #false
    #end
  #}

  # Settings specified here will take precedence over those in config/application.rb

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  ##config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  ##config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = false
  I18n.enforce_available_locales = false
end
