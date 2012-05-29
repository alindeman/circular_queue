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

    it "presents the appearance of accepting infinite items" do
      1.upto(capacity * 2) { |i| subject.enq(i) }

      1.upto(capacity) do |i|
        subject.deq.should == i + capacity
      end

      subject.size.should be_zero
    end

    it "raises an error if the queue is full and enq! is used to add items" do
      1.upto(capacity) { |i| subject.enq(i) }

      expect {
        subject.enq!(1)
      }.to raise_error(ThreadError)
    end
  end

  describe "removing items" do
    it "removes items from the queue until the queue is empty" do
      1.upto(capacity) { |i| subject.enq(i) }

      1.upto(capacity) do |i|
        subject.deq.should == i
      end

      subject.size.should be_zero
    end

    context "when empty" do
      context "non-blocking" do
        it "raises a ThreadError if the queue is empty" do
          subject.clear

          expect {
            subject.deq(true)
          }.to raise_error(ThreadError)
        end
      end

      context "blocking" do
        it "waits for another thread to add an item" do
          # Another queue that is doing work is required or a deadlock will
          # be detected
          enqueue = false
          done    = false

          enqueue_thread = Thread.new do
            until done
              subject.enq(1) if enqueue
            end
          end

          begin
            enqueue = true
            subject.deq.should == 1
          ensure
            done = true
          end
        end
      end
    end

    context "when full" do
      it "overrides elements at the beginning of the queue" do
        1.upto(capacity) { |i| subject.enq(i) }

        # Queue is full
        subject.enq(capacity + 1)

        # Returns the item that's been waiting the longest, not the overridden
        # value. 1 was overridden.
        subject.pop.should == 2
      end
    end
  end

  describe "clearing the queue" do
    it "removes all items from the queue" do
      subject.enq(1)
      subject.clear

      subject.size.should be_zero
    end
  end
end
