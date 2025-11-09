require "../fst/fst"
require "../dict/**"
require "../tokenizer_base"

module CrystalMoji::Viterbi
  class ViterbiBuilder
    @fst : CrystalMoji::FST::FST
    @dictionary : CrystalMoji::Dict::TokenInfoDictionary
    @unknown_dictionary : CrystalMoji::Dict::UnknownDictionary
    @user_dictionary : CrystalMoji::Dict::UserDictionary?
    @character_definitions : CrystalMoji::Dict::CharacterDefinitions
    @use_user_dictionary : Bool
    @search_mode : Bool

    def initialize(@fst, @dictionary, @unknown_dictionary, @user_dictionary, mode : CrystalMoji::TokenizerBase::Mode)
      @use_user_dictionary = !@user_dictionary.nil?
      @search_mode = (mode == CrystalMoji::TokenizerBase::Mode::Search || mode == CrystalMoji::TokenizerBase::Mode::Extended)
      @character_definitions = @unknown_dictionary.character_definition
    end

    def build(text : String) : ViterbiLattice
      text_length = text.size
      lattice = ViterbiLattice.new(text_length + 2)

      lattice.add_bos

      unknown_word_end_index = -1 # index of the last character of unknown word

      start_index = 0
      while start_index < text_length
        # If no token ends where current token starts, skip this index
        if lattice.token_ends_where_current_token_starts(start_index)
          suffix = text[start_index..-1]
          found = process_index(lattice, start_index, suffix)

          # In the case of normal mode, it doesn't process unknown word greedily.
          if @search_mode || unknown_word_end_index <= start_index
            categories = @character_definitions.lookup_categories(suffix[0])

            categories.each_with_index do |category, i|
              unknown_word_end_index = process_unknown_word(category, i, lattice, unknown_word_end_index, start_index, suffix, found)
            end
          end
        end
        start_index += 1
      end

      if @use_user_dictionary
        process_user_dictionary(text, lattice)
      end

      lattice.add_eos

      lattice
    end

    private def process_index(lattice : ViterbiLattice, start_index : Int32, suffix : String) : Bool
      found = false
      end_index = 1
      while end_index < suffix.size + 1
        prefix = suffix[0, end_index]
        result = @fst.lookup(prefix)

        if result > 0
          found = true # Don't produce unknown word starting from this index
          @dictionary.lookup_word_ids(result).each do |word_id|
            node = ViterbiNode.from_dict(word_id, prefix, @dictionary, start_index, ViterbiNode::Type::Known)
            lattice.add_node(node, start_index + 1, start_index + 1 + end_index)
          end
        elsif result < 0 # If result is less than zero, continue to next position
          break
        end
        end_index += 1
      end
      found
    end

    private def process_unknown_word(category : Int32, i : Int32, lattice : ViterbiLattice, unknown_word_end_index : Int32,
                                     start_index : Int32, suffix : String, found : Bool) : Int32
      unknown_word_length = 0
      definition = @character_definitions.lookup_definition(category)

      if definition[CrystalMoji::Dict::CharacterDefinitions.invoke] == 1 || !found
        if definition[CrystalMoji::Dict::CharacterDefinitions.group] == 0
          unknown_word_length = 1
        else
          unknown_word_length = 1
          j = 1
          while j < suffix.size
            c = suffix[j]

            categories = @character_definitions.lookup_categories(c)

            break if categories.nil?

            if i < categories.size && category == categories[i]
              unknown_word_length += 1
            else
              break
            end
            j += 1
          end
        end
      end

      if unknown_word_length > 0
        unk_word = suffix[0, unknown_word_length]
        word_ids = @unknown_dictionary.lookup_word_ids(category) # characters in input text are supposed to be the same

        word_ids.each do |word_id|
          node = ViterbiNode.from_dict(word_id, unk_word, @unknown_dictionary, start_index, ViterbiNode::Type::Unknown)
          lattice.add_node(node, start_index + 1, start_index + 1 + unknown_word_length)
        end
        unknown_word_end_index = start_index + unknown_word_length
      end

      unknown_word_end_index
    end

    private def process_user_dictionary(text : String, lattice : ViterbiLattice) : Nil
      return if @user_dictionary.nil?

      matches = @user_dictionary.not_nil!.find_user_dictionary_matches(text)

      matches.each do |match|
        word_id = match.word_id
        index = match.match_start_index
        length = match.match_length

        word = text[index, length]

        node = ViterbiNode.from_dict(word_id, word, @user_dictionary.not_nil!, index, ViterbiNode::Type::User)
        node_start_index = index + 1
        node_end_index = node_start_index + length

        lattice.add_node(node, node_start_index, node_end_index)

        if lattice_broken_before?(node_start_index, lattice)
          repair_broken_lattice_before(lattice, index)
        end

        if lattice_broken_after?(node_start_index + length, lattice)
          repair_broken_lattice_after(lattice, node_end_index)
        end
      end
    end

    private def lattice_broken_before?(node_index : Int32, lattice : ViterbiLattice) : Bool
      node_end_indices = lattice.end_index_arr
      node_end_indices[node_index].nil?
    end

    private def lattice_broken_after?(end_index : Int32, lattice : ViterbiLattice) : Bool
      node_start_indices = lattice.start_index_arr
      node_start_indices[end_index].nil?
    end

    private def repair_broken_lattice_before(lattice : ViterbiLattice, index : Int32) : Nil
      node_start_indices = lattice.start_index_arr

      start_index = index
      while start_index > 0
        if !node_start_indices[start_index].nil?
          glue_base = find_glue_node_candidate(index, node_start_indices[start_index]?.not_nil!, start_index)
          if !glue_base.nil?
            length = index + 1 - start_index
            surface = glue_base.surface[0, length]
            glue_node = make_glue_node(start_index, glue_base, surface)
            lattice.add_node(glue_node, start_index, start_index + glue_node.surface.size)
            return
          end
        end
        start_index -= 1
      end
    end

    private def repair_broken_lattice_after(lattice : ViterbiLattice, node_end_index : Int32) : Nil
      node_end_indices = lattice.end_index_arr

      end_index = node_end_index + 1
      while end_index < node_end_indices.size
        if !node_end_indices[end_index].nil?
          glue_base = find_glue_node_candidate(node_end_index, node_end_indices[end_index].not_nil!, end_index)
          if !glue_base.nil?
            delta = end_index - node_end_index
            glue_base_surface = glue_base.surface
            surface = glue_base_surface[glue_base_surface.size - delta, delta]
            glue_node = make_glue_node(node_end_index, glue_base, surface)
            lattice.add_node(glue_node, node_end_index, node_end_index + glue_node.surface.size)
            return
          end
        end
        end_index += 1
      end
    end

    private def find_glue_node_candidate(index : Int32, lattice_nodes : Array(ViterbiNode), start_index : Int32) : ViterbiNode?
      candidates = [] of ViterbiNode

      lattice_nodes.each do |viterbi_node|
        candidates << viterbi_node unless viterbi_node.nil?
      end

      unless candidates.empty?
        glue_base = nil
        length = index + 1 - start_index
        candidates.each do |candidate|
          if acceptable_candidate?(length, glue_base, candidate)
            glue_base = candidate
          end
        end
        return glue_base
      end

      nil
    end

    private def acceptable_candidate?(target_length : Int32, glue_base : ViterbiNode?, candidate : ViterbiNode) : Bool
      (glue_base.nil? || candidate.surface.size < glue_base.surface.size) &&
        candidate.surface.size >= target_length
    end

    private def make_glue_node(start_index : Int32, glue_base : ViterbiNode, surface : String) : ViterbiNode
      ViterbiNode.new(
        glue_base.word_id,
        surface,
        glue_base.left_id,
        glue_base.right_id,
        glue_base.word_cost,
        start_index,
        ViterbiNode::Type::Inserted
      )
    end
  end
end
