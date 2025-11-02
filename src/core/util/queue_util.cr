module CrystalMoji::Util
  # 最小堆实现的PriorityQueue
  class PriorityQueue(T)
    include Enumerable(T)

    @heap : Array(T)
    @compare : Proc(T, T, Bool)? = nil

    def initialize
      @heap = [] of T
      @compare = nil
    end

    def initialize(compare_fn : Proc(T, T, Bool))
      @heap = [] of T
      @compare = compare_fn
    end

    def push(value : T)
      @heap << value
      heapify_up(@heap.size - 1)
    end

    def pop : T?
      return nil if empty?

      if @heap.size == 1
        return @heap.pop
      end

      value = @heap[0]
      @heap[0] = @heap.pop
      heapify_down(0)
      value
    end

    def peek : T?
      @heap[0]?
    end

    def empty? : Bool
      @heap.empty?
    end

    def size : Int32
      @heap.size
    end

    def each(&block : T -> _)
      @heap.each(&block)
    end

    private def heapify_up(index : Int32)
      return if index == 0

      parent = (index - 1) // 2
      if compare(index, parent)
        @heap[index], @heap[parent] = @heap[parent], @heap[index]
        heapify_up(parent)
      end
    end

    private def heapify_down(index : Int32)
      left_child = 2 * index + 1
      right_child = 2 * index + 2
      smallest = index

      if left_child < @heap.size && compare(left_child, smallest)
        smallest = left_child
      end

      if right_child < @heap.size && compare(right_child, smallest)
        smallest = right_child
      end

      if smallest != index
        @heap[index], @heap[smallest] = @heap[smallest], @heap[index]
        heapify_down(smallest)
      end
    end

    private def compare(i : Int32, j : Int32) : Bool
      if !@compare.nil?
        @compare.not_nil!.call(@heap[i], @heap[j])
      else
        @heap[i] < @heap[j]
      end
    end
  end
end
