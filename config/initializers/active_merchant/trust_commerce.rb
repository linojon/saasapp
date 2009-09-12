# monkeypatch the gateway
# Lifted from Saasy http://github.com/maccman/saasy/tree/master
# This is to make their API a bit more like PaymentExpress's one
class TrustCommerceResponse < ActiveMerchant::Billing::Response
  def token
    @params["billingid"]
  end
end

ActiveMerchant::Billing::TrustCommerceGateway::Response = TrustCommerceResponse