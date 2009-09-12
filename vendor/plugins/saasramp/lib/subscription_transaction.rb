class SubscriptionTransaction < ActiveRecord::Base
  belongs_to  :subscription
  serialize   :params
  composed_of :amount, :class_name => 'Money', :mapping => [ %w(amount_cents cents) ], :allow_nil => true
  
  class << self
    # note, according to peepcode pdf, many gateways require a unique order_id on each transaction
    
    # validate card via transaction
    def validate_card( credit_card, options ={})
      options[:order_id] ||= unique_order_number
      # authorize $1
      amount = 100
      result = process( 'validate', amount ) do |gw|
        gw.authorize( amount, credit_card, options )
      end
      if result.success?
        # void it
        result = process( 'validate' ) do |gw|
          gw.void( result.reference, options )
        end
      end
      result
    end
    
    def store( credit_card, options = {})
      options[:order_id] ||= unique_order_number
      process( 'store' ) do |gw|
        gw.store( credit_card, options )
      end
    end

    def unstore( profile_key, options = {})
      options[:order_id] ||= unique_order_number
      process( 'unstore' ) do |gw|
        gw.unstore( profile_key, options )
      end
    end

    def charge( amount, profile_key, options ={})
      options[:order_id] ||= unique_order_number
      if SubscriptionConfig.gateway.respond_to?(:purchase)
        result = process( 'charge', amount ) do |gw|
          gw.purchase( amount, profile_key, options )
        end        
      else
        # do it in 2 transactions
        result = process( 'charge', amount ) do |gw|
          gw.authorize( amount, profile_key, options )
        end
        if result.success?
          result = process( 'charge', amount ) do |gw|
            gw.capture( amount, result.reference, options )
          end
        end
      end
      result
    end
    
    def credit( amount, profile_key, options = {})
      options[:order_id] ||= unique_order_number
      process( 'credit', amount) do |gw|
        gw.credit( amount, profile_key, options )
      end
    end

    # other possible transactions, not using at the moment
    
    # def authorize( amount, credit_card, options = {})
    #   process( 'authorization', amount) do |gw|
    #     gw.authorize( amount, credit_card, options )
    #   end
    # end
    # 
    # def capture( amount, authorization, options = {})
    #   process( 'capture', amount) do |gw|
    #     gw.capture( amount, authorization, options )
    #   end
    # end
    # 
    # def void( amount, authorization, options = {})
    #   process( 'void', amount) do |gw|
    #     gw.void( amount, authorization, options )
    #   end
    # end

    
    private
    
    def process( action, amount = nil)
      #debugger
      result = SubscriptionTransaction.new
      result.amount_cents = amount.is_a?(Money) ? amount.cents : amount
      #result.amount       = amount
      result.action       = action
      begin 
        response = yield SubscriptionConfig.gateway 

        result.success   = response.success? 
        result.reference = response.authorization 
        result.message   = response.message 
        result.params    = response.params 
        result.test      = response.test? 
      rescue ActiveMerchant::ActiveMerchantError => e 
        result.success   = false 
        result.reference = nil 
        result.message   = e.message 
        result.params    = {} 
        result.test      = SubscriptionConfig.gateway.test? 
      end 
      # TODO: LOGGING
      result 
    end 
    
    def unique_order_number
      "#{Time.now.to_i}-#{rand(1_000_000)}"
    end
  end
end
