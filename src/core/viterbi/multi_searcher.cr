require "../dict/**"
require "../tokenizer_base"
require "./viterbi_searcher"
require "./viterbi_node"

module CrystalMoji::Viterbi
  class MultiSearcher
    @costs : CrystalMoji::Dict::ConnectionCosts
    @mode : CrystalMoji::TokenizerBase::Mode
    @viterbi_searcher : CrystalMoji::Viterbi::ViterbiSearcher?
    @base_cost = 0
    @path_costs = [] of Int32
    @sidetracks : Hash(ViterbiNode, SidetrackEdge) = Hash(ViterbiNode, SidetrackEdge).new

    def initialize(@costs, @mode, @viterbi_searcher)
    end

    def get_shortest_paths(lattice : ViterbiLattice, max_count : Int32, cost_slack : Int32) : MultiSearchResult
      @path_costs = [] of Int32
      @sidetracks = {} of ViterbiNode => SidetrackEdge

      multi_search_result = MultiSearchResult.new
      build_sidetracks(lattice)

      eos = lattice.end_index_arr[0][0]
      @base_cost = eos.path_cost

      paths = get_paths(eos, max_count, cost_slack)

      paths.each_with_index do |path, i|
        nodes = generate_path(eos, path)
        multi_search_result.add(nodes, @path_costs[i])
      end

      multi_search_result
    end

    private def generate_path(eos : ViterbiNode, sidetrack_edge : SidetrackEdge?) : Array(ViterbiNode)
      result = Deque(ViterbiNode).new
      node = eos
      result.push(node)

      current_sidetrack = sidetrack_edge

      while node.left_node
        left_node = node.left_node

        if current_sidetrack && current_sidetrack.head == node
          left_node = current_sidetrack.tail
          current_sidetrack = current_sidetrack.parent
        end

        node = left_node
        result.unshift(node)
      end

      result.to_a
    end

    private def get_paths(eos : ViterbiNode, max_count : Int32, cost_slack : Int32) : Array(SidetrackEdge?)
      result = [] of SidetrackEdge?
      result << nil
      @path_costs << @base_cost

      sidetrack_heap = PriorityQueue(SidetrackEdge, Int32).new

      side_track_edge = @sidetracks[eos]?
      while side_track_edge
        sidetrack_heap.push(side_track_edge, side_track_edge.cost)
        side_track_edge = side_track_edge.next_option
      end

      (1...max_count).each do |i|
        break if sidetrack_heap.empty?

        side_track_edge = sidetrack_heap.pop
        break if side_track_edge.cost > cost_slack

        result << side_track_edge
        @path_costs << @base_cost + side_track_edge.cost

        next_sidetrack = @sidetracks[side_track_edge.tail]?

        while next_sidetrack
          next_edge = SidetrackEdge.new(next_sidetrack.cost, next_sidetrack.tail, next_sidetrack.head)
          next_edge.parent = side_track_edge
          sidetrack_heap.push(next_edge, next_edge.cost)
          next_sidetrack = next_sidetrack.next_option
        end
      end

      result
    end

    private def build_sidetracks(lattice : ViterbiLattice)
      start_index_arr = lattice.start_index_arr
      end_index_arr = lattice.end_index_arr

      (1...start_index_arr.size).each do |i|
        next unless start_index_arr[i] && end_index_arr[i]

        start_index_arr[i].each do |node|
          break unless node
          build_sidetracks_for_node(end_index_arr[i], node)
        end
      end
    end

    private def build_sidetracks_for_node(left_nodes : Array(ViterbiNode), node : ViterbiNode)
      backward_connection_id = node.left_id
      word_cost = node.word_cost

      sidetrack_edges = [] of SidetrackEdge
      next_option = @sidetracks[node.left_node]? if node.left_node

      left_nodes.each do |left_node|
        break unless left_node

        # Ignore BOS
        if left_node.type == ViterbiNode::Type::KNOWN && left_node.word_id == -1
          next
        end

        side_track_cost = left_node.path_cost - node.path_cost + word_cost +
                          @costs.get(left_node.right_id, backward_connection_id)

        if @mode.search? || @mode.extended?
          side_track_cost += @viterbi_searcher.penalty_cost(node)
        end

        if left_node != node.left_node
          sidetrack_edges << SidetrackEdge.new(side_track_cost, left_node, node)
        end
      end

      if sidetrack_edges.empty?
        @sidetracks[node] = next_option if next_option
      else
        (0...sidetrack_edges.size - 1).each do |i|
          sidetrack_edges[i].next_option = sidetrack_edges[i + 1]
        end
        sidetrack_edges.last.next_option = next_option
        @sidetracks[node] = sidetrack_edges.first
      end
    end

    class SidetrackEdge
      include Comparable(SidetrackEdge)

      property cost : Int32
      property tail : ViterbiNode
      property head : ViterbiNode
      property next_option : SidetrackEdge?
      property parent : SidetrackEdge?

      def initialize(@cost : Int32, @tail : ViterbiNode, @head : ViterbiNode)
        @next_option = nil
        @parent = nil
      end

      def parent=(parent : SidetrackEdge)
        @parent = parent
        @cost += parent.cost
      end

      def <=>(other : SidetrackEdge) : Int32
        @cost <=> other.cost
      end
    end
  end
end
