require "spec_helper"

describe CircularQueue do
  describe "initialization" do
    it "can be initialized with a capacity" do
      described_class.new(5).capacity.should == 5
    end
  end
end
