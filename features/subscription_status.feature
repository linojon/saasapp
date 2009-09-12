Feature: Subscription status
  In order to stay informed about my subscription status
	As a subscriber
  I see notices when I log in and look in my profile

	Scenario: Free plan, I see plan name in My Profile
		Given a subscriber with a "free" subscription
		When I log in
		And I go to my profile page
		#And (show me)
		Then I should see "Free"
		When I go to my subscription page
		And (show me)
		Then I should see "Free"
		And I should see "(no credit card on file)"

  Scenario: Paid plan, I see plan name in My Profile
		Given a subscriber with a "basic" subscription
		When I log in
		And I go to my profile page
		#And (show me)
		Then I should see "Basic"
		And I should see "Trial"
		When I go to my subscription page
		And (show me)
		Then I should see "Basic"
		And I should see "Trial"
		And I should see "Trial Period Ends:"
		And I should see "(no credit card on file)"

	Scenario: In trial, no credit card
		Given a subscriber with a "basic" subscription which is "in trial" and next renewal is "in 3 days" and profile is "no info"
		When I log in
		And (show me)
		Then I should see a notice saying "Trial subscription expires in 3 days"
		And I should see a notice saying "No credit card on file"
		When I go to my subscription page
		Then I should see "Trial Period Ends:"
		And I should see "(no credit card on file)"
		
	Scenario: In trial, with credit card
		Given a subscriber with a "basic" subscription which is "in trial" and next renewal is "in 3 days" and profile is "authorized"
		When I log in
		And (show me)
		Then I should see a notice saying "Trial subscription expires in 3 days"
		When I go to my subscription page
		Then I should see "Trial Period Ends:"
		And I should see "Bogus XXXX-XXXX-XXXX-1 Expires: 2012-10-31"
		
	Scenario: Active, with credit card
		Given a subscriber with a "basic" subscription which is "active" and next renewal is "in 3 days" and profile is "authorized"
		When I log in
		And I go to my subscription page
		Then I should see "Paid Through:"
		And I should see "Bogus XXXX-XXXX-XXXX-1 Expires: 2012-10-31"
	
	Scenario: Past due, with no credit card	
		Given a subscriber with a "basic" subscription which is "past due" and next renewal is "3 days ago" and profile is "no info"
		When I log in
		Then I should see a notice saying "No credit card on file"
		And I should see a notice saying "Please update your credit card information now, or this account will be downgraded to limited access in 4 days"
		When I go to my subscription page
		Then I should see "Account is past due. Please update your credit card information now."
		And I should see "(no credit card on file)"
		
  Scenario: Past due, with credit card error	
		Given a subscriber with a "basic" subscription which is "past due" and next renewal is "3 days ago" and profile is "error"
		When I log in
		Then I should see a notice saying "There was an error processing your credit card"
		And I should see a notice saying "Please update your credit card information now, or this account will be downgraded to limited access in 4 days"
		When I go to my subscription page
		Then I should see "Account is past due. Please update your credit card information now."
		And I should see "Bogus XXXX-XXXX-XXXX-1 Expires: 2012-10-31"
		And I should see "There was an error processing your credit card."
			
		