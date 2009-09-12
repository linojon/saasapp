# monkeypatch the gateway
#   allow an authorization id instead of cc
class ActiveMerchant::Billing::BogusGateway
# module ActiveMerchant #:nodoc:
#   module Billing #:nodoc:
#     class Bogus < Gateway

  # handle billing_id instead of credit card
  def purchase(money, creditcard_or_id, options = {})
    number = creditcard_or_id.is_a?(ActiveMerchant::Billing::CreditCard) ? creditcard_or_id.number : creditcard_or_id
    case number
    when '1', AUTHORIZATION
      ActiveMerchant::Billing::Response.new(true, SUCCESS_MESSAGE, {:authorized_amount => money.to_s}, :test => true, :authorization => AUTHORIZATION )
    when '2'
      ActiveMerchant::Billing::Response.new(false, FAILURE_MESSAGE, {:authorized_amount => money.to_s, :error => FAILURE_MESSAGE }, :test => true)
    else
      raise Error, ERROR_MESSAGE
    end      
  end
  
  # fix apparent blantant bug in bogus.rb
  # and modify to handle billing_id instead of credit card
  def credit(money, ident, options = {})
    case ident
    when '1', AUTHORIZATION
      Response.new(true, SUCCESS_MESSAGE, {:paid_amount => money.to_s}, :test => true)
    when '2'
      Response.new(false, FAILURE_MESSAGE, {:paid_amount => money.to_s, :error => FAILURE_MESSAGE }, :test => true)
    else
      raise Error, ERROR_MESSAGE
    end
  end
  
  
# end
# end
end

