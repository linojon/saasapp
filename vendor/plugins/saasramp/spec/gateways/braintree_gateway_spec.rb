require File.dirname(__FILE__) + '/../spec_helper'

describe BraintreeGateway do
  it "stores customer profile first time and gets customer key"
  it "updates customer profile using customer key"
  it "unstores customer profile"
  it "charges"
  it "voids"
  it "refunds"
  it "says if in_test_mode"
  
  describe "response" do
    it "returns billing key in token"
    it "returns nice error message"
    
  end
  
end
