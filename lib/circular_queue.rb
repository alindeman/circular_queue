require "thread"

class CircularQueue
  attr_reader :capacity

  attr_reader :size
  alias length size

  def initialize(capacity)
    @capacity = capacity
    @data     = Array.new(capacity)

    @mutex    = Mutex.new
    @waiting  = Array.new

    clear
  end

  def enq(item)
    @mutex.synchronize do
      enq_item(item)
      wakeup_next_waiter
    end
  end
  alias <<   enq
  alias push enq

  def enq!(item)
    @mutex.synchronize do
      raise ThreadError.new("Queue is full") if full?

      enq_item(item)
      wakeup_next_waiter
    end
  end
  alias push! enq!

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

  def num_waiting
    @waiting.length
  end

  private

  def enq_item(item)
    @data[@back] = item

    @size += 1 unless full?

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
