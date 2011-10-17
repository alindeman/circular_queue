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

  describe "removing items" do
    before do
      1.upto(capacity) { |i| subject.enq(i) }
    end

    it "removes items from the queue until the queue is empty" do
      1.upto(capacity) do |i|
        subject.deq.should == i
      end

      subject.size.should be_zero
    end

    it "raises a ThreadError if the queue is empty" do
      subject.clear

      expect {
        subject.deq
      }.to raise_error(ThreadError)
    end
  end
end
