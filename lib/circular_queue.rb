require "thread"

# A thread-safe queue with a size limitation. When more elements than the
# capacity are added, the queue either loops back on itself (removing the
# oldest elements first) or raises an error (if `enq!` is used).
#
# Useful for streaming data where keeping up with real-time is more important
# than consuming every message if load rises and the queue backs up.
#
# Exposes the same interface as the `Queue` from the Ruby stdlib.
#
# Example:
#
#     # Capacity of 3
#     q = CircularQueue.new(3)
#
#     q << 1 # => [1]
#     q << 2 # => [1, 2]
#     q << 3 # => [1, 2, 3]
#
#     # Elements are replaced when the queue reaches capacity
#     q << 4 # => [2, 3, 4]
#     q << 5 # => [3, 4, 5]
class CircularQueue
  # Returns the maximum number of elements that can be enqueued
  # @return [Integer]
  attr_reader :capacity

  # Returns the number of elements in the queue
  # @return [Integer]
  attr_reader :size
  alias length size

  # Creates a new queue of the specified capacity
  # @param [Integer] capacity the maximum capacity of the queue
  def initialize(capacity)
    @capacity = capacity
    @data     = Array.new(capacity)

    @mutex    = Mutex.new
    @waiting  = Array.new

    clear
  end

  # Adds an item to the queue
  # @param [Object] item item to add
  def enq(item)
    @mutex.synchronize do
      enq_item(item)
      wakeup_next_waiter
    end
  end
  alias <<   enq
  alias push enq

  # Adds an item to the queue, raising an error if the queue is full
  # @param [Object] item item to add
  # @raise [ThreadError] queue is full
  def enq!(item)
    @mutex.synchronize do
      raise ThreadError.new("Queue is full") if full?

      enq_item(item)
      wakeup_next_waiter
    end
  end
  alias push! enq!

  # Removes an item from the queue
  # @param [Boolean] non_block true to raise an error if the queue is empty;
  #                  otherwise, waits for an item to arrive from another thread
  # @raise [ThreadError] non_block was true and the queue was empty
  def deq(non_block = false)
    @mutex.synchronize do
      while true
        if empty?
          raise ThreadError.new("Queue is empty") if non_block

          @waiting.push(Thread.current) unless @waiting.include?(Thread.current)
          @mutex.sleep
        else
          return deq_item
        end
      end
    end
  end
  alias shift deq
  alias pop   deq

  # Removes all items from the queue
  def clear
    @mutex.synchronize do
      @size  = 0
      @front = 0
      @back  = 0
    end
  end

  # Returns whether the queue is empty
  # @return [Boolean] queue is empty
  def empty?
    @size == 0
  end

  # Returns whether the queue is full
  # @return [Boolean] queue is full
  def full?
    @size == @capacity
  end

  # Returns the number of threads waiting for items to arrive in the queue
  # @return [Integer] number of threads waiting
  def num_waiting
    @waiting.length
  end

  private

  def enq_item(item)
    @data[@back] = item

    if full?
      @front += 1
      @front %= @capacity
    else
      @size += 1
    end

    @back += 1
    @back %= @capacity
  end

  def deq_item
    item = @data[@front]

    @size  -= 1

    @front += 1
    @front %= @capacity

    item
  end

  def wakeup_next_waiter
    begin
      if thread = @waiting.shift
        thread.wakeup
      end
    rescue ThreadError
      retry
    end
  end
end
