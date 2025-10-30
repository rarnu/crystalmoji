module CrystalMoji::FST
  class FSTFormatter
    @@font_name = "Helvetica"

    def format(builder : Builder, out_file_name : String) : String
      sb = String::Builder.new
      sb << format_header
      sb << format_hashed_nodes(builder)
      sb << format_trailer
      begin
        File.write(out_file_name, sb.to_s)
      rescue e
        puts e
      end
      ""
    end

    private def format_header : String
      String::Builder.new.tap do |sb|
        sb << "digraph fst {\n"
        sb << "graph [ fontsize=30 labelloc=\"t\" label=\"\" splines=true overlap=false rankdir = \"LR\" ];\n"
        sb << "# A2 paper size\n"
        sb << "size = \"34.4,16.5\";\n"
        sb << "# try to fill paper\n"
        sb << "ratio = fill;\n"
        sb << "edge [ fontname=\"#{@@font_name}\" fontcolor=\"red\" color=\"#606060\" ]\n"
        sb << "node [ peripheries=2 style=\"filled\" fillcolor=\"#e8e8f0\" shape=\"Mrecord\" fontsize=40 fontname=\"#{@@font_name}\" ]\n"
      end.to_s
    end

    private def format_trailer : String
      "}"
    end

    private def format_hashed_nodes(builder : Builder) : String
      sb = String::Builder.new
      sb << format_state(builder.get_start_state) # format the start state

      state_array = [] of State
      state_array << builder.get_start_state

      while !state_array.empty?
        state = state_array[0]
        if state.arcs.size == 0 || state.visited
          state_array.delete_at(0)
          next
        end

        state.get_all_transition_strings.each do |transition|
          arc = state.find_arc(transition) || Arc.new(0, State.new, '\0')
          to_state = arc.get_destination
          state_array << to_state

          if to_state.final?
            sb << format_final_state(to_state)
          else
            sb << format_state(to_state)
          end

          arc_output = arc.output
          sb << format_edge(state, to_state, transition, arc_output.to_s, "fontsize=40")
        end

        state.visited = true
        state_array.delete_at(0)
      end

      sb.to_s
    end

    private def format_state(state : State) : String
      String::Builder.new.tap do |sb|
        sb << "\""
        sb << get_node_id(state)
        sb << "\""
        sb << " [ "
        sb << "label="
        sb << format_state_label(state)
        sb << " ]"
      end.to_s
    end

    private def format_final_state(state : State) : String
      String::Builder.new.tap do |sb|
        sb << "\""
        sb << get_node_id(state)
        sb << "\""
        sb << " [ "
        sb << "fillcolor=pink "
        sb << "label="
        sb << format_final_state_label(state)
        sb << " ]"
      end.to_s
    end

    private def format_state_label(state : State) : String
      String::Builder.new.tap do |sb|
        sb << "<<table border=\"0\" cellborder=\"0\">"
        sb << "<tr><td>"
        sb << "Node"
        sb << "</td></tr>"
        sb << "<tr><td>"
        sb << "<font color=\"blue\">"
        sb << "Normal State"
        sb << "</font>"
        sb << "</td></tr>"
        sb << "</table>>"
      end.to_s
    end

    private def format_final_state_label(state : State) : String
      String::Builder.new.tap do |sb|
        sb << "<<table border=\"0\" cellborder=\"0\">"
        sb << "<tr><td>"
        sb << "Node"
        sb << "</td></tr>"
        sb << "<tr><td>"
        sb << "<font color=\"blue\">"
        sb << "Accepting State"
        sb << "</font>"
        sb << "</td></tr>"
        sb << "</table>>"
      end.to_s
    end

    private def format_edge(from : State, to : State, transition : Char, output : String, attributes : String) : String
      String::Builder.new.tap do |sb|
        sb << get_node_id(from)
        sb << " -> "
        sb << get_node_id(to)
        sb << " [ "
        sb << "label=\""
        sb << transition
        sb << "/"
        sb << output
        sb << "\""
        sb << " "
        sb << attributes
        sb << " "
        sb << " ]"
        sb << "\n"
      end.to_s
    end

    private def get_node_id(node : State) : String
      node.hash.to_s
    end

  end
end
