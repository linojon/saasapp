module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name.downcase
    
    when /the homepage/
      '/'
    when /the new info page/
      new_info_path
    when /the infos list page/
      infos_path
    when /my profile page/
      user_path(:current)
    when /my subscription/
      subscription_path(:current)
    when /the credit card page/
      credit_card_subscription_path(:current)
      
    when /login/
      login_path
    when /signup/
      signup_path
      
      
      
    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
