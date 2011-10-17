require "spec_helper"

describe CircularQueue do
  let(:capacity) { 5 }
  subject        { described_class.new(capacity) }

  describe "initialization" do
    it "can be initialized with a capacity" do
      subject.capacity.should == capacity
    end
  end

  describe "adding items" do
    it "accepts new items" do
      subject.enq(1234)
      subject.deq.should == 1234
    end

    it "increases its size when a new item is added" do
      subject.enq(1234)
      subject.size.should == 1
    end
  end
end
