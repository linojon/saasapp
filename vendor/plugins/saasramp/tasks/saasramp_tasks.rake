namespace :subscription do
  
  desc "Seeds or updates the subscription_plans table data from db/subscription_plans.yml. Note, if plan name exists it will be updated with any new values. For production db run with RAILS_ENV=production"
  task :plans => :environment do
    file = RAILS_ROOT + '/db/subscription_plans.yml'
    if ! File.exists?(file)
      puts "#{file} not found."
      return
    end
    base_name = File.basename(file, '.*')
    puts "Loading #{base_name}..."
    raw = File.read(file)
    data = YAML.load(raw)[RAILS_ENV].symbolize_keys
    data[:plans].each do |params|
      params.symbolize_keys!
      if plan = SubscriptionPlan.find_by_name( params[:name] )
        plan.attributes = params
        if plan.changed?
          if plan.save
            puts "updated '#{params[:name]}'"
          else
            puts "error updating '#{params[:name]}'"
            puts plan.errors.full_messages.inspect
          end
        else
          puts "no changes to '#{params[:name]}'"
        end
      else
        plan = SubscriptionPlan.create( params )
        if plan.new_record?
          puts "error creating '#{params[:name]}'"
          puts plan.errors.full_messages.inspect
        else
          puts "created '#{params[:name]}'"
        end
      end  
    end  
  end
  
  desc "Daily subscription processing, including renewals and email messages"
  task :daily => :environment do
    Lockfile('subscription_daily_lock', :retries => 0) do
      Subscription.process_trial_warnings
      Subscription.process_renewals
      Subscription.process_expire_warnings
      Subscription.process_expirations
    end
  end
 # ======================     
 #      # set past_due states
 #      Subscription.update_all_dueness
 #      
 #      # renew
 #      Subscription.past_due.each {|sub| 
 #        if sub.renew
 #          SubscriptionMailer.deliver_charge_success(sub)
 #        else
 #          SubscriptionMailer.deliver_charge_failure(sub)
 #        end
 #      }
      
      # # past due, 2nd try or 2nd warning
      # Subscription.in_state(:past_due).due(time - 3.days).each {|sub| 
      #   if sub.renew!
      #     SubscriptionMailer.deliver_charge_success(sub)
      #   else
      #     SubscriptionMailer.deliver_second_charge_failure(sub)
      #   end
      # }
      #      
      # # past due, 3rd try or last warning and downgrade
      # Subscription.in_state(:past_due).due(time - 6.days).each {|sub| 
      #   if sub.renew!
      #     SubscriptionMailer.deliver_charge_success(sub)
      #   else
      #     ## You may want to disable the person's
      #     ## account here, but initally I'm going
      #     ## to do it manually
      #     # sub.account.disable!
      #     SubscriptionMailer.deliver_account_failure(sub.account)
      #   end
      # }
      
    
    # ------------
    # trial period ending soon with no credit card
    # trial period ended with no credit card
    # renewal
    # renewal charge error
    # past due charge retry
end
