# # default plan name when user has no subscription. Defaults to the first plan with rate==0. Must be a plan with rate==0 since no billing occurs. 
# default_plan: free
# 
# # what plan to assign to subscriptions that have expired (may be nil) (defaults to default_plan). Must be a plan with rate==0 since no billing occurs. 
# expired_plan: free
# 
# # trial period length (days) before first billing (can be 0 for no trial) (default = 30)
# trial_period: 30
# 
# # grace period length (days) after subscription is past due before it is expired (closed down)
# grace_period: 7
# 
# # where to send admin reports (nil for no emails)
# admin_report_recipients: jonathan@parkerhill.com
# 
# # shortcut configuration of the ActiveMerchant gateway
# #  test sets the Billing mode
# test: true
# 
# #  gateway is the name of the gateway, passed to ActiveMerchant::Billing::Base.gateway(name)
# gateway_name: braintree
# 
# # login credentials to the gateway
# login: testapi
# password: password1
# 
# # other options passed to #new when initializing the gateway
# # gateway_options: 
# #   foo: bar
# #   baz: bam
# 
# # when true then card is validated by authorizing for $1 (and then void) [always false for bogus gateway]
# validate_via_transaction: true

class SubscriptionConfig  
  def self.load
    config_file = File.join(Rails.root, "config", "subscription.yml")

    if File.exists?(config_file)
      text = ERB.new(File.read(config_file)).result
      hash = YAML.load(text)
      config = hash.stringify_keys[Rails.env]
      config.keys.each do |key|
        cattr_accessor key
        send("#{key}=", config[key])
      end
    end
  end
  
  # this is initialized to an instance of ActiveMerchant::Billing::Base.gateway
  cattr_accessor :gateway
  
  def self.bogus?
    gateway.is_a? ActiveMerchant::Billing::BogusGateway
  end
  
end
SubscriptionConfig.load