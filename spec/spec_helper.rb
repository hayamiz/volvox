require 'rubygems'
require 'spork'
require 'cover_me' if RUBY_VERSION =~ /\A1\.9\./

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
end

Spork.each_run do
  # This code will be run each time you run your specs.

  # reload app codes
  Dir["#{Rails.root}/app/**/*.rb"].each { |f| load f }
end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading 
#   code that you don't normally modify during development in the 
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.
#




# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  def test_sign_in(user)
    controller.sign_in(user)
  end

  def integration_sign_in(user)
    visit signin_path
    fill_in :email,	:with => user.email
    fill_in :password,	:with => user.password
    click_button
  end
end


CoverMe.config do |c|
  # where is your project's root:
  c.project.root = Rails.root
  # what files are you interested in coverage for:
  c.file_pattern = [
    /(#{CoverMe.config.project.root}\/app\/.+\.rb)/i,
    /(#{CoverMe.config.project.root}\/lib\/.+\.rb)/i
  ]
  
  # what files do you want to explicitly exclude from coverage
  c.exclude_file_patterns = []

  # where do you want the HTML generated:
  c.html_formatter.output_path = File.join(CoverMe.config.project.root, 'coverage')

  # what do you want to happen when it finishes:
#   c.at_exit = Proc.new {
#     if CoverMe.config.formatter == CoverMe::HtmlFormatter
#       index = File.join(CoverMe.config.html_formatter.output_path, 'index.html')
#       if File.exists?(index)
#         `open #{index}`
#       end
#     end
#   }
end
