Feature: Manage infos
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Home page
		Given I am on the homepage
		Then I should see "Welcome to Infos"
		And I should see "Login or Sign up"
		
	Scenario: Cannot manage infos when not logged in
		Given I am on the homepage
		When I go to the infos list page
		Then I should be on the login page
		And I should see "You must first log in or sign up before accessing this page."
		
	Scenario: Home page has link to infos when logged in
		Given a user is logged in as "subscriber"
		And I am on the homepage
		Then I should see "View Private Infos"
	
  Scenario: Register new info
		Given a user is logged in as "subscriber"
    And I am on the new info page
    When I fill in "Title" with "title 1"
    And I fill in "Body" with "body 1"
    And I press "Submit"
    Then I should see "title 1"
    And I should see "body 1"

  Scenario: Delete info
		Given a user is logged in as "subscriber"
    Given the following infos:
      |title|body|
      |title 1|body 1|
      |title 2|body 2|
      |title 3|body 3|
      |title 4|body 4|
    When I delete the 3rd info
    Then I should see the following infos:
      |Title|Body|
      |title 1|body 1|
      |title 2|body 2|
      |title 4|body 4|

		
		