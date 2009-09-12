Feature: Subscription credit card
  In order to keep my subscription
	As a subscriber
  I want to maintain my credit card info

	Scenario: I add credit card info
		Given a subscriber with a "basic" subscription which is "in trial" and next renewal is "in 3 days" and profile is "no info"
		When I log in
		And I go to my subscription page
		Then I should see "(no credit card on file)"
		When I press "Update Credit Card"
		And I fill out the credit card form correctly
		And I press "Submit"
		And (show me)
		Then I should be on my subscription page
		And I should see "Credit card info has been securely stored. No charges have been made at this time."
		And I should see "Bogus XXXX-XXXX-XXXX-1 Expires: 2012-10-31"
		And the profile should be "authorized"
	
	Scenario: I add credit card info, get errors
		Given a subscriber with a "basic" subscription which is "in trial" and next renewal is "in 3 days" and profile is "no info"
		When I log in
		And I go to my subscription page
		Then I should see "(no credit card on file)"
		When I press "Update Credit Card"
		And I fill out the credit card form with errors
		And I press "Submit"
		And (show me)
		Then I should see "prohibited this profile from being saved"

  Scenario: I add credit card info, get errors
		Given a subscriber with a "basic" subscription which is "in trial" and next renewal is "in 3 days" and profile is "no info"
		When I log in
		And I go to my subscription page
		Then I should see "(no credit card on file)"
		When I press "Update Credit Card"
		And I fill out the credit card form with invalid card
		And I press "Submit"
		And (show me)
		Then I should see "Failed to store card"
			
	Scenario: I update my credit card info, no errors
		Given a subscriber with a "basic" subscription which is "in trial" and next renewal is "in 3 days" and profile is "authorized"
		When I log in
		And I go to my subscription page
		Then I should see "Bogus XXXX-XXXX-XXXX-1 Expires: 2012-10-31"
		When I press "Update Credit Card"
		And I fill out the credit card form with month: 11
		And I press "Submit"
		And (show me)
		Then I should be on my subscription page
		And I should see "Credit card info has been securely stored. No charges have been made at this time."
		And I should see "Bogus XXXX-XXXX-XXXX-1 Expires: 2012-11-30"
		And the profile should be "authorized"
		
	
	Scenario: I update my credit card info, with errors
	
	Scenario: I remove my credit card
	
	
	Scenario: Subscription is past due, I add credit card info
		Given a subscriber with a "basic" subscription which is "past due" and next renewal is "3 days ago" and profile is "no info"
		When I log in
		And I go to my subscription page
		Then I should see "no credit card on file"
		When I press "Update Credit Card"
		And I fill out the credit card form correctly
		And I press "Submit"
		Then I should be on my subscription page
		And I should see "Thank you for your payment. Your credit card has been charged $10.00"
		And I should see "Bogus XXXX-XXXX-XXXX-1 Expires: 2012-10-31"
		And the profile should be "authorized"
		And a "charge" transaction should be created
		And the next renewal should be set to "original renewal plus interval"
		
	Scenario: I can see my transaction history
		Given a subscriber with a "basic" subscription which is "in trial" and next renewal is "in 3 days" and profile is "no info"
		When I log in
		And I go to the credit card page
		And I fill out the credit card form correctly
		And I press "Submit"
		When I press "Update Credit Card"
		And I fill out the credit card form with month: 11
		And I press "Submit"
		When I follow "History"
		And (show me)
		# useless asserts, need something more precise
		Then I should see "Store"
		And I should see "Unstore"
	