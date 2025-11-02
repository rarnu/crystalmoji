require "./viterbi_node"

module CrystalMoji::Viterbi
  class MultiSearchResult
    @tokenized_results : Array(Array(ViterbiNode))
    @costs : Array(Int32)

    def initialize
      @tokenized_results = Array(Array(ViterbiNode)).new
      @costs = Array(Int32).new
    end

    def add(tokenized_result : Array(ViterbiNode), cost : Int32)
      @tokenized_results << tokenized_result
      @costs << cost
    end

    def get_tokenized_result(index : Int32) : Array(ViterbiNode)
      @tokenized_results[index]
    end

    def get_tokenized_results_list : Array(Array(ViterbiNode))
      @tokenized_results
    end

    def get_cost(index : Int32) : Int32
      @costs[index]
    end

    def size : Int32
      @costs.size
    end


  end
end
