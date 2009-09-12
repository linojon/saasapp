# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] ||= "cucumber"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'

# Comment out the next line if you don't want Cucumber Unicode support
require 'cucumber/formatter/unicode'

# Comment out the next line if you don't want transactions to
# open/roll back around each scenario
Cucumber::Rails.use_transactional_fixtures

# Comment out the next line if you want Rails' own error handling
# (e.g. rescue_action_in_public / rescue_responses / rescue_from)
Cucumber::Rails.bypass_rescue

require 'webrat'
require 'cucumber/webrat/element_locator' # Lets you do table.diff!(element_at('#my_table_or_dl_or_ul_or_ol').to_table)

Webrat.configure do |config|
  config.mode = :rails
end

require 'cucumber/rails/rspec'
require 'webrat/core/matchers'

# see http://wiki.github.com/aslakhellesoy/cucumber/fixtures
raw = File.read( RAILS_ROOT + '/db/subscription_plans.yml' )
data = YAML.load(raw)[RAILS_ENV].symbolize_keys
data[:plans].each {|params| SubscriptionPlan.create( params ) }

def show_me
  # remove: \ # ? & + = %2
  name = response.request.request_uri.gsub('&amp;','-').gsub(/[\/\#\?&\+\=(%2)]/,'-')
  File.open(RAILS_ROOT + "/public/cucumber/#{name}.html", "w"){ |f| f.puts response.body }
  system "open -a Firefox.app http://localhost:3000/cucumber/#{name}.html" 
end

