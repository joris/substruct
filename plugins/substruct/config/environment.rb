# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode
# (Use only when you can't set environment variables through your web/app server)
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  config.load_paths += %W( #{RAILS_ROOT}/vendor/plugins/substruct )
  config.action_controller.session_store = :active_record_store

  # It seems Rack 1.1.0 SPECIFICALLY is required by Rails 2.3.8
  config.gem "rack", :version => '1.1.0'
  
  config.gem 'RedCloth', :lib => 'redcloth'
  config.gem 'fastercsv'
  config.gem 'mime-types', :lib => 'mime/types'
  config.gem 'mini_magick', :version => '1.3.3'
  config.gem 'ezcrypto'
  
  # All of these gems are just so we can attach inline-css styles
  # to the order receipt HTML email! :(
  config.gem 'css_parser'
  config.gem 'text-hyphen', :lib => 'text/hyphen'
  config.gem 'text-reform', :lib => 'text/reform'
  config.gem 'htmlentities'
  # http://github.com/SunDawg/premailer
  config.gem 'sundawg_premailer', :lib => 'premailer'
end