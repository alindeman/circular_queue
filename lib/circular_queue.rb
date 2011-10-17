require "thread"

class CircularQueue
  attr_reader :capacity

  attr_reader :size
  alias :length :size

  def initialize(capacity)
    @capacity = capacity
    @data     = Array.new(capacity)

    @size     = 0
    @front    = 0
  end

  def enq(item)
    @data[back] = item
    @size += 1
  end
  alias :<<   :enq
  alias :push :enq

  def deq
    raise ThreadError if empty?

    item = @data[@front]

    @size  -= 1
    @front += 1

    item
  end
  alias :shift :deq
  alias :pop   :deq

  def clear
    @size  = 0
    @front = 0
  end

  def empty?
    @size == 0
  end

  private

  def back
    (@front + @size) % @capacity
  end
end