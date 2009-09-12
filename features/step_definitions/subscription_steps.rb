Given /^a subscriber with a "(.*)" subscription$/ do |plan|
  @current_user = create_user( :subscription_plan => SubscriptionPlan.find_by_name(plan) )
end

Given /^a subscriber with a "(.*)" subscription which is "(.*)" and next renewal is "(.*)" and profile is "(.*)"$/ do |plan, subs_state, date_text, profile_state |
  #debugger
  #Given a subscriber with a "basic" subscription which is "in trial" and next renewal is "in 3 days" and profile is "no info"
  @current_user = create_user( :subscription_plan => SubscriptionPlan.find_by_name(plan) )
  set_current_subscription_state( subs_state )
  set_current_renewal( date_text )
  set_current_profile_state( profile_state )
  # beware this is not safe in all scenarios
  @original_renewal = @current_user.subscription.next_renewal_on
end

When /^I fill out the credit card form (correctly|with errors|with invalid card)$/ do |what|
  case what
  when 'correctly'
    params = SubscriptionProfile.example_credit_card_params
  when 'with errors'
    params = SubscriptionProfile.example_credit_card_params( :first_name => '')
  when 'with invalid card'
    params = SubscriptionProfile.example_credit_card_params( :number => '2')
  else
    puts 'step error: unknown "what"'
  end
  params.each do |field, value|
    name = "profile_credit_card_#{field}" #assuming view as form_for :profile ... form.feldsfor :credit_card
    begin
      select value, :from => name
    rescue
      fill_in name, :with => value
    end
  end
end

When /^I fill out the credit card form with (.*): (.*)$/ do |field, value|
  params = SubscriptionProfile.example_credit_card_params
  params[field.to_sym] = value
  params.each do |field, value|
    name = "profile_credit_card_#{field}" #assuming view as form_for :profile ... form.feldsfor :credit_card
    begin
      select value, :from => name
    rescue
      fill_in name, :with => value
    end
  end
end


Then /^"(.*)" should have subscription "(.*)": "(.*)"$/ do |username, attribute, value|
  user = User.find_by_username(username)
  case attribute
  when 'plan': 
    user.subscription_plan.name.should == value
    
  when 'state':
    user.subscription.state.should == value
    
  when 'next_renewal_on':
    case value
    when '30 days'
      user.subscription.next_renewal_on.should == (Time.now.midnight + 30.days).to_date
    when 'next month'
      user.subscription.next_renewal_on.should == (Time.now.midnight + 1.month).to_date
    when "next year"
      user.subscription.next_renewal_on.should == (Time.now.midnight + 1.year).to_date
    when "nil"
      user.subscription.next_renewal_on.should be_nil
    end
    
  else
    puts 'unknown attribute'
  end
end

Then /^the profile should be "(.*)"$/ do |state|
  #@current_user.subscription.profile.reload
  @current_user.reload
  @current_user.subscription.profile.state.to_s.should == state.downcase
end

Then /^a "(.*)" transaction should be created$/ do |action|
  @current_user.subscription.latest_transaction.action.should == action
end

Then /^the next renewal should be set to "(.*)"$/ do |text|
  #debugger
  @current_user.reload
  @current_user.subscription.next_renewal_on.should == renewal_date_from_text(text)
end

# support

def set_current_subscription_state( text )
  unless ['pending', 'free', 'trial', 'active', 'past due'].include? text
    puts "bad case in set_current_subscription_text"
    return
  end
  @current_user.subscription.state = text.gsub(' ','_')
  @current_user.subscription.save
end

def set_current_renewal( text )
  case text
  when 'in 3 days'
    @current_user.subscription.next_renewal_on = (Time.now.midnight + 3.days).to_date
  when '3 days ago'
    @current_user.subscription.next_renewal_on = (Time.now.midnight - 3.days).to_date
  else
    puts "bad case in set_current_renewal"
  end
  @current_user.subscription.save
end

def set_current_profile_state( text )
  profile = @current_user.subscription.profile || @current_user.subscription.build_profile
  case text
  when 'no info'
    profile.state = 'no_info'
  when 'authorized', 'error'
     # fake it for now, not really on gateway
    params = SubscriptionProfile.example_credit_card_params
    profile.profile_key         = 'some key'
    profile.card_first_name     = params[:first_name]
    profile.card_last_name      = params[:last_name]
    profile.card_type           = params[:type]
    profile.card_display_number = 'XXXX-XXXX-XXXX-1'
    profile.card_expires_on     = '2012-10-31'
    if text == 'error'
      profile.state = 'error'
    else
      profile.state = 'authorized'
    end
    profile.save
  else
    puts 'bad case in set_current_profile_state'
  end
  profile.save
end

def renewal_date_from_text(text)
  subscription = @current_user.subscription
  case text
  when 'original renewal plus interval'
    @original_renewal + subscription.plan.interval.months
  else
    puts 'bad case in renewal_date_from_text'
  end
end
