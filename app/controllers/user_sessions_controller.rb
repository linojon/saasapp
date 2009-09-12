class UserSessionsController < ApplicationController
  include ActionView::Helpers::TextHelper #for pluralize

  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      # (move this into a helper)
      sub = current_user.subscription
      msgs = ["Logged in successfully"]
      msgs << "Trial subscription expires in #{pluralize sub.days_remaining, 'day'}" if sub.trial?
      msgs << "No credit card on file" if sub.profile.no_info? && sub.due?(7)
      msgs << "There was an error processing your credit card" if sub.profile.error?
      msgs << "Please update your credit card information now, or this account will be downgraded to limited access in #{pluralize sub.grace_days_remaining, 'day'}" if sub.past_due?  
			flash[:notice] = msgs.join('. ')

      redirect_to_target_or_default(root_url)
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    flash[:notice] = "You have been logged out."
    redirect_to root_url
  end
end
