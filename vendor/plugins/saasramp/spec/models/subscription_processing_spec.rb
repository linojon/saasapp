require File.dirname(__FILE__) + '/../spec_helper'

# note, mailer specs are a bit redundant with the subscription_observer spec but
# i like having them here too so the daily processing spec is more complete

describe Subscription, "processing tasks" do
  before :all do
    ActiveRecord::Observer.allow_peeping_toms = true
  end
  before :each do
    mailer_setup
    create_subscription_plans unless @free
    @today = Time.zone.today
  end
  after :all do
    ActiveRecord::Observer.allow_peeping_toms = false
  end
  
  # -------------------------
  describe "process_trial_warnings" do
    before :each do
      @subscriber = create_subscriber( :username => 'guy', :subscription_plan => @basic)
      @subscriber.subscription.update_attributes :next_renewal_on => @today + 3.days
      Subscription.process_trial_warnings
    end
    
    it "should deliver trial warning email" do
      number_of_emails_sent.should == 1
      last_email_sent.subject.should =~ /Your trial is ending soon/
    end
    
    it "should increment the warning level" do
      @subscriber.reload
      @subscriber.subscription.warning_level.should == 1
    end
    
    it "should not send duplicate message" do
      number_of_emails_sent.should == 1
      Subscription.process_trial_warnings
      number_of_emails_sent.should == 1
    end
  end

  # -------------------------
  describe "process_renewals" do
    before :each do
      @subscriber = create_subscriber( :username => 'guy', :subscription_plan => @basic)
      @subscriber.subscription.update_attributes :state => 'active', :next_renewal_on => @today
      @subscriber.subscription.profile.update_attributes :state => 'authorized', :profile_key => '1'
    end
    
    it "should renew active subscriptions" do
      Subscription.process_renewals
      @subscriber.reload
      @subscriber.subscription.should be_active
      @subscriber.subscription.next_renewal_on.should == @today + 1.month
    end
    
    it "should not renew subscriptions that are not due" do
      @subscriber.subscription.update_attributes :next_renewal_on => @today + 1.day
      Subscription.process_renewals
      @subscriber.reload

      @subscriber.subscription.should be_active
      @subscriber.subscription.next_renewal_on.should == @today + 1.day
    end
      
    it "should activate trials that ended" do
      @subscriber.subscription.update_attributes :state => 'trial'
      Subscription.process_renewals
      @subscriber.reload
      
      @subscriber.subscription.should be_active
      @subscriber.subscription.next_renewal_on.should == @today + 1.month
    end

    it "should send charge_success emails" do
      Subscription.process_renewals
      number_of_emails_sent.should == 1
      last_email_sent.subject.should =~ /Service invoice/
    end
    
    describe "with bad credit card" do
       before :each do
         @subscriber.subscription.profile.update_attribute :profile_key, '2'
         Subscription.process_renewals
         @subscriber.reload
       end
       it "should set past_due" do         
         @subscriber.subscription.should be_past_due
       end
       it "should send charge_failed emails" do
         number_of_emails_sent.should == 1
         last_email_sent.subject.should =~ /Billing error/
       end
     end
  end
  
  # -------------------------
  describe "process_expire_warnings" do
    before :each do
      @subscriber = create_subscriber( :username => 'guy', :subscription_plan => @basic)
      # say its been 3 days since tried to renew
      @subscriber.subscription.update_attributes :state => 'past_due', :balance => @basic.rate, :next_renewal_on => @today - 3.days, :warning_level => 1
      @subscriber.subscription.profile.update_attributes :state => 'error', :profile_key => '2'
    end
   
    it "should deliver expire warning email" do
      Subscription.process_expire_warnings
      number_of_emails_sent.should == 1
      last_email_sent.subject.should =~ /Second notice: Your subscription is set to expire/
    end
    
    it "should increment the warning level" do
      Subscription.process_expire_warnings
      @subscriber.reload
      @subscriber.subscription.warning_level.should == 2
    end
    
    it "should not send duplicate message" do
      Subscription.process_expire_warnings
      number_of_emails_sent.should == 1
      Subscription.process_expire_warnings
      number_of_emails_sent.should == 1
    end
    
    it "should renew if credit card info is ok" do
      @subscriber.subscription.profile.update_attribute :profile_key, '1'
      Subscription.process_expire_warnings
      number_of_emails_sent.should == 1
      last_email_sent.subject.should =~ /Service invoice/
      @subscriber.reload
      @subscriber.subscription.should be_active
      @subscriber.subscription.next_renewal_on.should == @today - 3.days + 1.month 
    end
  end
  
  # -------------------------
  describe "process_expirations" do
    before :each do
      @subscriber = create_subscriber( :username => 'guy', :subscription_plan => @basic)
      # end of grace
      @subscriber.subscription.update_attributes :state => 'past_due', :balance => @basic.rate, :next_renewal_on => @today - 7.days, :warning_level => 2
      @subscriber.subscription.profile.update_attributes :state => 'error', :profile_key => '2'
    end
  
    it "should set expired" do    
      Subscription.process_expirations
      @subscriber.reload
      @subscriber.subscription.should be_expired
    end
    it "should deliver expired email" do
      Subscription.process_expirations
      number_of_emails_sent.should == 1
      last_email_sent.subject.should =~ /Your subscription has expired/
    end
    it "should renew if credit card info is ok" do
      @subscriber.subscription.profile.update_attribute :profile_key, '1'
      Subscription.process_expirations
      number_of_emails_sent.should == 1
      last_email_sent.subject.should =~ /Service invoice/
      @subscriber.reload
      @subscriber.subscription.should be_active
      @subscriber.subscription.next_renewal_on.should == @today - 7.days + 1.month 
    end
  end
end
