Given /^a user "(.*)"$/ do |username|
  @current_user = create_user( :username => username )
end

Given /^a user is logged in as "(.*)"$/ do |username|
  @current_user = create_user( :username => username )
  
  visit "/login" 
  fill_in("user_session_username", :with => username) 
  fill_in("password", :with => 'secret') 
  click_button("Log in")
  response.body.should =~ /Logged/m  
end

When /^I fill out the signup form$/ do
  fill_in("username", :with => 'subscriber') 
  fill_in("password", :with => 'secret') 
  fill_in("confirm password", :with => 'secret') 
  fill_in("email", :with => 'subscriber@example.com') 
end

When /^I log in$/ do
  visit "/login" 
  fill_in("user_session_username", :with => 'subscriber') 
  fill_in("password", :with => 'secret') 
  click_button("Log in")  
end

def create_user( options = {} )
  args = {
    :username => 'subscriber',
    :password => 'secret',
    :password_confirmation => 'secret',
  }.merge( options )
  args[:email] ||= "#{args[:username]}@example.com"
  user = User.create!(args)
  # :create syntax for restful_authentication w/ aasm. Tweak as needed.
  # user.activate! 
  user
end