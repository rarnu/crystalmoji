require "../dict/**"
require "./multi_searcher"
require "../tokenizer_base"

module CrystalMoji::Viterbi
  class ViterbiSearcher
    @@default_cost : Int32 = 0x7fffffff

    @costs : CrystalMoji::Dict::ConnectionCosts
    @unknown_dictionary : CrystalMoji::Dict::UnknownDictionary
    @kanji_penalty_length_threshold : Int32
    @other_penalty_length_threshold : Int32
    @kanji_penalty : Int32
    @other_penalty : Int32
    @mode : CrystalMoji::TokenizerBase::Mode
    @multi_searcher : CrystalMoji::Viterbi::MultiSearcher?

    def initialize(@mode, @costs, @unknown_dictionary, penalties : Array(Int32))
      if !penalties.empty?
        @kanji_penalty_length_threshold = penalties[0]
        @kanji_penalty = penalties[1]
        @other_penalty_length_threshold = penalties[2]
        @other_penalty = penalties[3]
      else
        @kanji_penalty_length_threshold = 0
        @kanji_penalty = 0
        @other_penalty_length_threshold = 0
        @other_penalty = 0
      end

      @multi_searcher = CrystalMoji::Viterbi::MultiSearcher.new(@costs, mode, self)
    end

    def search(lattice : ViterbiLattice) : Array(ViterbiNode)
      end_index_arr = calculate_path_costs(lattice)
      result = backtrack_best_path(end_index_arr[0][0])
      result
    end

    def search_multiple(lattice : ViterbiLattice, max_count : Int32, cost_slack : Int32) : MultiSearchResult
      calculate_path_costs(lattice)
      result = @multi_searcher.get_shortest_paths(lattice, max_count, cost_slack)
      result
    end

    private def calculate_path_costs(lattice : ViterbiLattice) : Array(Array(ViterbiNode))
      start_index_arr = lattice.start_index_arr
      end_index_arr = lattice.end_index_arr

      (1...start_index_arr.size).each do |i|
        # continue since no array which contains ViterbiNodes exists. Or no previous node exists.
        next if start_index_arr[i].nil? || end_index_arr[i].nil?

        start_index_arr[i].each do |node|
          # If array doesn't contain ViterbiNode any more, continue to next index
          break if node.nil?

          update_node(end_index_arr[i], node)
        end
      end
      end_index_arr
    end

    private def update_node(viterbi_nodes : Array(ViterbiNode), node : ViterbiNode) : Nil
      backward_connection_id = node.left_id
      word_cost = node.word_cost
      least_path_cost = DEFAULT_COST

      viterbi_nodes.each do |left_node|
        # If array doesn't contain any more ViterbiNodes, continue to next index
        break if left_node.nil?

        # cost = [total cost from BOS to previous node] + [connection cost between previous node and current node] + [word cost]
        path_cost = left_node.path_cost +
                    @costs.get(left_node.right_id, backward_connection_id) +
                    word_cost

        # Add extra cost for long nodes in "Search mode".
        if @mode == TokenizerBase::Mode::SEARCH || @mode == TokenizerBase::Mode::EXTENDED
          path_cost += get_penalty_cost(node)
        end

        # If total cost is lower than before, set current previous node as best left node (previous means left).
        if path_cost < least_path_cost
          least_path_cost = path_cost
          node.path_cost = least_path_cost
          node.left_node = left_node
        end
      end
    end

    def get_penalty_cost(node : ViterbiNode) : Int32
      path_cost = 0
      surface = node.surface
      length = surface.size

      if length > @kanji_penalty_length_threshold
        if kanji_only?(surface) # Process only Kanji keywords
          path_cost += (length - @kanji_penalty_length_threshold) * @kanji_penalty
        elsif length > @other_penalty_length_threshold
          path_cost += (length - @other_penalty_length_threshold) * @other_penalty
        end
      end
      path_cost
    end

    private def kanji_only?(surface : String) : Bool
      surface.each_char do |c|
        # In Crystal, we need a way to check if a character is a Kanji (CJK Unified Ideograph)
        # This is a simplified check - you might need a more robust implementation
        # based on the Unicode ranges for CJK Unified Ideographs
        unless c.kanji?
          return false
        end
      end
      true
    end

    private def backtrack_best_path(eos : ViterbiNode) : Array(ViterbiNode)
      node = eos
      result = [] of ViterbiNode

      result << node

      while true
        left_node = node.left_node

        break if left_node.nil?

        # Extended mode converts unknown word into unigram nodes
        if @mode == TokenizerBase::Mode::EXTENDED && left_node.type == ViterbiNode::Type::UNKNOWN
          uni_gram_nodes = convert_unknown_word_to_unigram_node(left_node)
          result.concat(uni_gram_nodes)
        else
          result.unshift(left_node)
        end
        node = left_node
      end
      result
    end

    private def convert_unknown_word_to_unigram_node(node : ViterbiNode) : Array(ViterbiNode)
      uni_gram_nodes = [] of ViterbiNode
      unigram_word_id = 0
      surface = node.surface

      surface.size.downto(1) do |i|
        word = surface[i - 1, 1]
        start_index = node.start_index + i - 1

        uni_gram_node = ViterbiNode.new(unigram_word_id, word, @unknown_dictionary, start_index, ViterbiNode::Type::UNKNOWN)
        uni_gram_nodes.unshift(uni_gram_node)
      end

      uni_gram_nodes
    end
  end
end
