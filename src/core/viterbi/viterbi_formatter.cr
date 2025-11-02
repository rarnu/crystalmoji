require "../dict/connection_costs"
require "./viterbi_node"
require "./viterbi_lattice"

module CrystalMoji::Viterbi

  class ViterbiFormatter

    @@bos_label : String = "BOS"
    @@eos_label : String = "EOS"
    @@font_name : String = "Helvetica"

    @costs : CrystalMoji::Dict::ConnectionCosts
    @node_map : Hash(String, ViterbiNode)
    @best_path_map : Hash(String, String)
    @found_bos : Bool = false

    def initialize(@costs : CrystalMoji::Dict::ConnectionCosts)
      @node_map = Hash(String, ViterbiNode).new
      @best_path_map = Hash(String, String).new
    end

    def format(lattice : ViterbiLattice) : String
      format(lattice, nil)
    end

    def format(lattice : ViterbiLattice, best_path : Array(ViterbiNode)?) : String
      init_best_path_map(best_path)

      String.build do |builder|
        builder << format_header
        builder << format_nodes(lattice)
        builder << format_trailer
      end
    end

    private def init_best_path_map(best_path : Array(ViterbiNode)?) : Nil
      @best_path_map.clear

      return if best_path.nil?

      (0...best_path.size - 1).each do |i|
        from = best_path[i]
        to = best_path[i + 1]

        from_id = get_node_id(from)
        to_id = get_node_id(to)

        @best_path_map[from_id] = to_id
      end
    end

    private def format_nodes(lattice : ViterbiLattice) : String
      starts_array = lattice.start_index_arr
      ends_array = lattice.end_index_arr
      @node_map.clear
      @found_bos = false

      String.build do |builder|
        (1...ends_array.size).each do |i|
          next if ends_array[i].nil? || starts_array[i].nil?

          ends_array[i].each do |from|
            next if from.nil?

            builder << format_node_if_new(from)

            starts_array[i].each do |to|
              break if to.nil?

              builder << format_node_if_new(to)
              builder << format_edge(from, to)
            end
          end
        end
      end
    end

    private def format_node_if_new(node : ViterbiNode) : String
      node_id = get_node_id(node)
      unless @node_map.has_key?(node_id)
        @node_map[node_id] = node
        return format_node(node)
      else
        return ""
      end
    end

    private def format_header : String
      String.build do |builder|
        builder << "digraph viterbi {\n"
        builder << "graph [ fontsize=30 labelloc=\"t\" label=\"\" splines=true overlap=false rankdir = \"LR\" ];\n"
        builder << "# A2 paper size\n"
        builder << "size = \"34.4,16.5\";\n"
        builder << "# try to fill paper\n"
        builder << "ratio = fill;\n"
        builder << "edge [ fontname=\"#{FONT_NAME}\" fontcolor=\"red\" color=\"#606060\" ]\n"
        builder << "node [ style=\"filled\" fillcolor=\"#e8e8f0\" shape=\"Mrecord\" fontname=\"#{FONT_NAME}\" ]\n"
      end
    end

    private def format_trailer : String
      "}"
    end

    private def format_edge(from : ViterbiNode, to : ViterbiNode) : String
      from_id = get_node_id(from)

      if @best_path_map.has_key?(from_id) && @best_path_map[from_id] == get_node_id(to)
        format_edge_with_attributes(from, to, "color=\"#40e050\" fontcolor=\"#40a050\" penwidth=3 fontsize=20 ")
      else
        format_edge_with_attributes(from, to, "")
      end
    end

    private def format_edge(from : ViterbiNode, to : ViterbiNode, attributes : String) : String
      String.build do |builder|
        builder << get_node_id(from)
        builder << " -> "
        builder << get_node_id(to)
        builder << " [ "
        builder << "label=\""
        builder << get_cost(from, to)
        builder << "\""
        builder << " "
        builder << attributes
        builder << " "
        builder << " ]"
        builder << "\n"
      end
    end

    private def format_node(node : ViterbiNode) : String
      String.build do |builder|
        builder << "\""
        builder << get_node_id(node)
        builder << "\""
        builder << " [ "
        builder << "label="
        builder << format_node_label(node)

        case node.type
        when ViterbiNode::Type::USER
          builder << " fillcolor=\"#e8f8e8\""
        when ViterbiNode::Type::UNKNOWN
          builder << " fillcolor=\"#f8e8f8\""
        when ViterbiNode::Type::INSERTED
          builder << " fillcolor=\"#ffe8e8\""
        end

        builder << " ]\n"
      end
    end

    private def format_node_label(node : ViterbiNode) : String
      String.build do |builder|
        builder << "<<table border=\"0\" cellborder=\"0\">"
        builder << "<tr><td>"
        builder << get_node_label(node)
        builder << "</td></tr>"
        builder << "<tr><td>"
        builder << "<font color=\"blue\">"
        builder << node.word_cost
        builder << "</font>"
        builder << "</td></tr>"
        builder << "</table>>"
      end
    end


    private def get_node_id(node : ViterbiNode) : String
      node.hash.to_s
    end

    private def get_node_label(node : ViterbiNode) : String
      if node.type == ViterbiNode::Type::KNOWN && node.word_id == 0
        if @found_bos
          EOS_LABEL
        else
          @found_bos = true
          BOS_LABEL
        end
      else
        node.surface
      end
    end

    private def get_cost(from : ViterbiNode, to : ViterbiNode) : Int32
      @costs.get(from.left_id, to.right_id)
    end

  end
end
