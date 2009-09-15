require File.dirname(__FILE__) + '/../spec_helper'

describe AuthorizeNetCimGateway do
  before :all do
    ActiveMerchant::Billing::Base.mode = :test
    
    gateway_params = {
      :login    => '5Lh6pXSLh2sU',      # API login
      :password => '2c33558GR3mcNeTj',   # API transaction key
      :test => true 
    }
    @gateway = ActiveMerchant::Billing::Base.gateway('authorize_net_cim').new( gateway_params )
    
    cc_params = credit_card_hash( 
      :type               => 'visa',
      :number             => '4007000000027',
      :verification_value => '999'
    )
    @cc = ActiveMerchant::Billing::CreditCard.new( cc_params ) 
    @amount = 995
  end

  it "store customer profile and gets customer key" do
    response = @gateway.store( @cc )
    response.should be_success
  end
  
  it "unstore customer profile" do
    response = @gateway.store( @cc )
    @key = response.token
    response = @gateway.unstore( @key )
    response.should be_success
  end
  
  describe "with key" do
    # re-use the same key for the rest of these
    before :all do
      response = @gateway.store( @cc )
      @key = response.token
    end

    it "update customer profile using customer key"
  
    it "authorize a charge on credit card (for validation)" do
      response = @gateway.authorize( @amount, @key )
      pp response
      response.should be_success
    end

    it "purchase" do
      response = @gateway.purchase( @amount, @key )
      response.should be_success
    end
  
    it "credit back an amount" do
      pending "disabled for Authorized.net because they discourage using it"
      response = @gateway.credit( @amount, @key)
      response.should be_success
    end

    describe "with transaction id" do
      before :each do
        response = @gateway.authorize( @amount, @key )
        #pp response
        response.should be_success  
        @trans_id = response.token #params['direct_response']['transaction_id']      
      end
          
      it "voids a charge on credit card (for validation)" do
        response = @gateway.void( @amount, @trans_id )
        #pp response
        response.should be_success
      end

      it "refunds a charge" do
        response = @gateway.refund( @trans_id, :amount => @amount, :billing_id => @key )
        debugger
        response.should be_success
      end
    end
    
  end
end
