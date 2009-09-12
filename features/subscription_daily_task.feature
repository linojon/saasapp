Feature: Subscription
  In order to maintain paid subscriptions
	As an administrator
  I want to process the account daily

	Scenario: Trial period ending soon with no credit card
		Given a subscriber with a "basic" subscription which is "in trial" and next renewal is "in 3 days" and profile is "no info"
		When the nightly task is run
		Then the subscription should be "in trial"
		And the subscriber should receive a "Trial Expiring" email

	Scenario: Trial period ending soon with authorized credit card
		Given a subscriber with a "basic" subscription which is "in trial" and next renewal is "in 3 days" and profile is "authorized"
		When the nightly task is run
		Then the subscription should be "in trial"
		And the subscriber should not receive an email
		
	Scenario: Trial period has ended with no credit card
		Given a subscriber with a "basic" subscription which is "in trial" and next renewal is "now" and profile is "no info"
		When the nightly task is run
		Then the subscription should be "past due"
		And the profile should be "error"
		And the subscriber should receive a "Billing Error" email
		And the next renewal should be set to "now plus grace period"
		
	Scenario: Trial period has ended with authorized credit card
		Given a subscriber with a "basic" subscription which is "in trial" and next renewal is "now" and profile is "authorized"
		When the nightly task is run
		Then the subscription should be "active"
		And the profile should be "authorized"
		And a "success" transaction should be created
		And the subscriber should receive an "Invoice" email
		And the next renewal should be set to "now plus interval"
	
	Scenario: Active subscription is renewed
		Given a subscriber with a "basic" subscription which is "active" and next renewal is "now" and credit card is "valid"
		When the nightly task is run
		Then the subscription should be "active"
		And the profile should be "authorized"
		And a "success" transaction should be created
		And the subscriber should receive an "Invoice" email
		And the next renewal should be set to "renewal plus interval"
		
	Scenario: Error charging subscription past due
		Given a subscriber with a "basic" subscription which is "active" and next renewal is "now" and credit card is "invalid"
		When the nightly task is run
		Then the subscription should be "past due"
		And the profile should be "error"
		And a "error" transaction should be created
		And the subscriber should receive an "Billing Error" email
		And the next renewal should be set to "now plus grace period"
		
	Scenario: Subscription is past due and credit card is now valid
		Given a subscriber with a "basic" subscription which is "past due" and next renewal is "past grace" and credit card is "valid"
		When the nightly task is run
		Then the subscription should be "active"
		And the profile should be "authorized"
		And a "success" transaction should be created
		And the subscriber should receive an "Invoice" email
		And the next renewal should be set to "original renewal plus interval"

  Scenario: Subscription is past grace and credit card is still invalid
		Given a subscriber with a "basic" subscription which is "past due" and next renewal is "past grace" and credit card is "invalid"
		When the nightly task is run
		Then the subscription should be "cancelled"
		And the profile should be "error"
		And a "error" transaction should be created
		And the subscriber should receive an "Subscription Cancelled" email
		And the next renewal should be set to "nil"
		# in reviewramp, cancelled accounts have all their projects closed, then goes to a free plan with no projects, existing projects show in the My list but the links are disabled
		
		
		
		
