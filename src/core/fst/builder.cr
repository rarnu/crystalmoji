require "./state"
require "./compiler"

module CrystalMoji::FST
  class Builder
    @states_dictionary : Hash(Int32, Array(State))
    @compiler : Compiler = Compiler.new
    @temp_states : Array(State)

    def initialize
      state_list = [] of State
      state_list << State.new
      @states_dictionary = Hash(Int32, Array(State)).new
      @states_dictionary[0] = state_list

      @temp_states = [] of State
      @temp_states << get_start_state
    end

    def build(input_words : Array(String), output_values : Array(Int32)?)
      previous_word = ""
      0.upto(input_words.size - 1) do |input_word_idx|
        input_word = input_words[input_word_idx]
        self.create_dictionary_common(
          input_word,
          previous_word,
          output_values == nil ? input_word_idx + 1 : output_values[input_word_idx]
        )
        previous_word = input_word
      end
      self.handle_last_word(previous_word)
    end

    def transduce(input : String) : Int32
      current_state = get_start_state
      output = 0
      0.upto(input.size - 1) do |i|
        current_transition = input[i]
        next_arc = current_state.find_arc(current_transition)
        if next_arc == nil
          return -1
        end
        current_state = next_arc.try(&.get_destination) || State.new
        output += next_arc.try(&.output) || 0
      end

      output
    end

    def get_start_state
      @states_dictionary[0][0]
    end

    def get_compiler
      @compiler
    end

    private def find_equivalent_state(state : State) : State
      key = state.hash
      if @states_dictionary.has_key?(key)
        if state.arcs.size == 0
          return @states_dictionary[key][0]
        end

        @states_dictionary[key].each do |cs|
          if state == cs
            return cs
          end
        end
      end

      new_state_to_dic = State.new(state)
      state_list = [] of State

      if @states_dictionary.has_key?(key)
        state_list = @states_dictionary[key]
      end

      state_list << new_state_to_dic
      @states_dictionary[key] = state_list

      new_state_to_dic
    end

    private def exclude_prefix(word : Int32, prefix : Int32) : Int32
      word - prefix
    end

    private def common_prefix_indice(prev_word : String, current_word : String) : Int32
      i = 0
      while i < prev_word.size && i < current_word.size
        break if prev_word[i] != current_word[i]
        i += 1
      end
      i
    end

    private def compile_starting_state
      @compiler.compile_state(@temp_states[0])
    end

    private def handle_last_word(previous_word : String)
      previous_word.size.downto(1) do |i|
        freeze_and_point_to_new_state(previous_word, i)
      end
      compile_starting_state
      find_equivalent_state(@temp_states[0])
    end

    private def freeze_and_point_to_new_state(previous_word : String, i : Int32)
      state = @temp_states[i - 1]
      previous_word_char = previous_word[i - 1]
      output = state.find_arc(previous_word_char).try(&.output) || 0
      state.arcs.delete(state.find_arc(previous_word_char))
      arc_to_frozen_state = state.set_arc(previous_word_char, output, find_equivalent_state(@temp_states[i]))
      @compiler.compile_state(arc_to_frozen_state.get_destination)
    end

    private def create_dictionary_common(input_word : String, previous_word : String, current_output : Int32)
      common_prefix_length_plus_one = common_prefix_indice(previous_word, input_word) + 1
      if input_word.size >= @temp_states.size
        @temp_states.size.upto(input_word.size) do |_|
          @temp_states << State.new
        end
      end
      previous_word.size.downto(common_prefix_length_plus_one) do |i|
        freeze_and_point_to_new_state(previous_word, i)
      end
      common_prefix_length_plus_one.upto(input_word.size) do |i|
        @temp_states[i] = State.new
        @temp_states[i - 1].set_arc(input_word[i - 1], @temp_states[i])
      end
      @temp_states[input_word.size].set_final

      current_state = @temp_states[0]
      0.upto(common_prefix_length_plus_one - 2) do |i|
        next_arc = current_state.find_arc(input_word[i])
        current_output = exclude_prefix(current_output, next_arc.try(&.output) || 0)
        current_state = next_arc.try(&.get_destination) || State.new
      end
      suffix_head_state = @temp_states[common_prefix_length_plus_one - 1]
      suffix_head_state.find_arc(input_word[common_prefix_length_plus_one - 1]).try(&.output = current_output)
    end
  end
end
