require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Wtools
  DOMAIN = 'wtools.cn'
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
		config.autoload_paths += %W(#{Rails.root}/app/models/observers)
		config.autoload_paths += %W(#{Rails.root}/app/controllers/sweepers)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    config.active_record.observers = :change_gold_count_observer,
			:reply_observer,
			:set_user_log_observer,
			:task_log_observer,
			:task_observer,
			:user_observer

		# Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
		config.time_zone = 'Beijing'
		config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = 'zh-CN'

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password,:password_confirmation]

    config.action_mailer.default_url_options = { :host => 'wtool.cn' }
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.perform_deliveries = true
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.smtp_settings = {
			:location       => '/usr/sbin/sendmail',
			:arguments      => '-i -t'
    }

		#		config.middleware.use ExceptionNotifier,
		#			:email_prefix => "[Wtools 错误邮件] ",
		#			:sender_address => %{"notifier" <exception.sender@wtools.cn>},
		#			:exception_recipients => %w{xuhao@rubyfans.com}

    #config.xx = 


  end
end
