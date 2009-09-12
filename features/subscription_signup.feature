Feature: Subscribe
  In order to use subscription based services
	As a subscriber
  I want to maintain my subscription

	Scenario Outline: I sign up for an account
		Given I am on the homepage
		When I follow "Sign up"
		Then I should be on the signup page
		When I fill out the signup form
		And I select "<PLAN>" from "Subscription plan"
		And I press "Sign up"
		Then I should be on the homepage
		And I should see "Thank you for signing up! You are now logged in."
		
		Then "subscriber" should have subscription "plan": "<PLAN>"
		And "subscriber" should have subscription "state": "<STATE>"
		And "subscriber" should have subscription "next_renewal_on": "<RENEWAL>"
		
		Examples:
		| PLAN  | STATE  | RENEWAL |
		| free  | free   | nil     |
		| basic | trial  | 30 days |
		| pro   | trial  | 30 days |
	
	Scenario: I cancel my subscription
	
	
	
	