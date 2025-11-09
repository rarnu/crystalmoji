module CrystalMoji::Viterbi
  class ViterbiLattice
    class_property bos : String = "BOS"
    class_property eos : String = "EOS"

    @dimension : Int32

    getter start_index_arr : Array(Array(ViterbiNode?)?)
    getter end_index_arr : Array(Array(ViterbiNode?)?)
    getter start_size_arr : Array(Int32)
    getter end_size_arr : Array(Int32)

    def initialize(@dimension)
      @start_index_arr = Array(Array(ViterbiNode?)?).new(@dimension, nil)
      @end_index_arr = Array(Array(ViterbiNode?)?).new(@dimension, nil)
      @start_size_arr = Array(Int32).new(@dimension, 0)
      @end_size_arr = Array(Int32).new(@dimension, 0)
    end

    def add_bos
      bos_node = ViterbiNode.new(-1, ViterbiLattice.bos, 0, 0, 0, -1, ViterbiNode::Type::Known)
      add_node(bos_node, 0, 1)
    end

    def add_eos
      eos_node = ViterbiNode.new(-1, ViterbiLattice.eos, 0, 0, 0, @dimension - 1, ViterbiNode::Type::Known)
      add_node(eos_node, @dimension - 1, 0)
    end

    def add_node(node : ViterbiNode, start : Int32, _end : Int32)
      add_node_to_array(node, start, @start_index_arr, @start_size_arr)
      add_node_to_array(node, _end, @end_index_arr, @end_size_arr)
    end

    private def add_node_to_array(node : ViterbiNode, index : Int32, arr : Array(Array(ViterbiNode?)?), sizes : Array(Int32))
      count = sizes[index]
      expand_if_needed(index, arr, count)
      arr[index].not_nil![count] = node
      sizes[index] = count + 1
    end

    private def expand_if_needed(index : Int32, arr : Array(Array(ViterbiNode?)?), count : Int32)
      if count == 0
        arr[index] = Array(ViterbiNode?).new(10, nil)
      end

      if arr[index].not_nil!.size <= count
        arr[index] = extend_array(arr[index].not_nil!)
      end
    end

    private def extend_array(array : Array(ViterbiNode?)) : Array(ViterbiNode?)
      new_array = Array(ViterbiNode?).new(array.size * 2, nil)
      array.each_with_index do |item, i|
        new_array[i] = item
      end
      new_array
    end

    def token_ends_where_current_token_starts(start_index : Int32) : Bool
      @end_size_arr[start_index + 1] != 0
    end

  end
end
