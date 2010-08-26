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
end

# Include your application configuration below
require 'rubygems'
gem 'RedCloth'
gem 'fastercsv'

begin
  Preference.init_mail_settings()
rescue
  puts "[SUBSTRUCT WARNING]"
  puts "Mail server settings have not been initialized."
  puts "Check to make sure they've been set in the admin panel."
  # Don't care if this bombs out, because initially this won't have a value.
end

# Globals
ERROR_EMPTY  = 'Please fill in this field.'
ERROR_NUMBER = 'Please enter only numbers (0-9) in this field.'