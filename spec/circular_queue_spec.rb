RSpec.describe CircularQueue do
  let(:capacity) { 5 }
  subject(:queue) { described_class.new(capacity) }

  describe "initialization" do
    it "can be initialized with a capacity" do
      expect(queue.capacity).to eq(capacity)
    end
  end

  describe "adding items" do
    it "accepts new items" do
      queue.enq(1234)
      expect(queue.front).to eq(1234)
      expect(queue.back).to eq(1234)
      expect(queue.deq).to eq(1234)
    end

    it "maintains the same API as Queue, returning itself" do
      expect(queue.enq(1)).to eq(queue)
      expect(queue.enq!(2)).to eq(queue)
    end

    it "increases its size when a new item is added" do
      queue.enq(1234)
      expect(queue.size).to eq(1)
    end

    it "allows for peeking at first and last items" do
      queue.enq(1)

      expect(queue.front).to eq(1)
      expect(queue.back).to eq(1)

      2.upto(capacity) { |i| queue.enq(i) }
      expect(queue.front).to eq(1)
      expect(queue.back).to eq(capacity)
    end

    it "presents the appearance of accepting infinite items" do
      1.upto(capacity * 2) { |i| queue.enq(i) }

      1.upto(capacity) do |i|
        expect(queue.deq).to eq(i + capacity)
      end

      expect(queue.size).to be_zero
    end

    it "raises an error if the queue is full and enq! is used to add items" do
      1.upto(capacity) { |i| queue.enq(i) }

      expect {
        queue.enq!(1)
      }.to raise_error(ThreadError)
    end
  end

  describe "removing items" do
    it "removes items from the queue until the queue is empty" do
      1.upto(capacity) { |i| queue.enq(i) }

      1.upto(capacity) do |i|
        expect(queue.deq).to eq(i)
      end

      expect(queue.size).to be_zero
    end

    context "when empty" do
      context "non-blocking" do
        it "raises a ThreadError if the queue is empty" do
          queue.clear

          expect {
            queue.deq(true)
          }.to raise_error(ThreadError)
        end
      end

      context "blocking" do
        it "waits for another thread to add an item" do
          # Another queue that is doing work is required or a deadlock will
          # be detected
          enqueue = false
          done    = false

          Thread.new do
            until done
              queue.enq(1) if enqueue
            end
          end

          begin
            enqueue = true
            expect(queue.deq).to eq(1)
          ensure
            done = true
          end
        end
      end
    end

    context "when full" do
      it "overrides elements at the beginning of the queue" do
        1.upto(capacity) { |i| queue.enq(i) }

        # Queue is full
        queue.enq(capacity + 1)

        # Returns the item that's been waiting the longest, not the overridden
        # value. 1 was overridden.
        expect(queue.pop).to eq(2)
      end
    end
  end

  describe "clearing the queue" do
    it "removes all items from the queue" do
      queue.enq(1)
      queue.clear

      expect(queue.size).to be_zero
    end

    it "maintains the same API as Queue, returning itself" do
      expect(queue.clear).to eq(queue)
    end
  end

  describe "data" do
    it "allows taking a snapshot of the data in the queue" do
      queue.enq(1)
      queue.enq(2)
      queue.enq(3)
      queue.deq

      expect(queue.data).to eq([2, 3])
    end
  end
end
