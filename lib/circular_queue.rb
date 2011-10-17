require "thread"

class CircularQueue
  attr_reader :capacity

  attr_reader :size
  alias :length :size

  def initialize(capacity)
    @capacity = capacity
    @data     = Array.new(capacity)

    @mutex    = Mutex.new

    clear
  end

  def enq(item)
    @mutex.synchronize do
      @data[@back] = item

      @size += 1 unless full?

      @back += 1
      @back %= @capacity
    end
  end
  alias :<<   :enq
  alias :push :enq

  def enq!(item)
    @mutex.synchronize do
      raise ThreadError.new("Queue is full") if full?
      enq(item)
    end
  end
  alias :push! :enq!

  def deq
    @mutex.synchronize do
      raise ThreadError.new("Queue is empty") if empty?

      item = @data[@front]

      @size  -= 1

      @front += 1
      @front %= @capacity

      item
    end
  end
  alias :shift :deq
  alias :pop   :deq

  def clear
    @mutex.synchronize do
      @size  = 0
      @front = 0
      @back  = 0
    end
  end

  def empty?
    @size == 0
  end

  def full?
    @size == @capacity
  end
end
