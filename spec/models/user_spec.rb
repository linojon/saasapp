require File.dirname(__FILE__) + '/../spec_helper'
describe User do

  it_should_behave_like "acts as subscriber"
  
  describe "states" do
    it "can be pending"
    it "can be active"
    it "can be suspended"
    it "can activate"
    it "can suspend"
    it "can unsuspend"
  end
end
