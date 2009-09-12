Then /^I should see a message "(.*)"$/ do |msg|
  
end

Then /^I should see (a|an) (\S*) saying "(.*)"$/ do |_, flash, message|
  # eg <p id="notice">Logged in</p>
  response.should have_tag("div#flash_#{flash.downcase}", /#{Regexp.escape message}/ ) 
end

Then /^I should not see (a|an) (\S*)$/ do |_, flash|
  response.should_not have_tag("div#flash_#{flash.downcase}" ) 
end


Then /^\(show me\)$/ do
  show_me
  #versus save_and_open_page
end
