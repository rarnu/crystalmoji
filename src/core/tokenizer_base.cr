require "./viterbi/**"
require "./dict/**"
require "./util/resource_resolver"
require "./fst/fst"

module CrystalMoji
  abstract class TokenizerBase(T)
    enum Mode
      Normal
      Search
      Extended
    end

    @viterbiBuilder : CrystalMoji::Viterbi::ViterbiBuilder?
    @viterbi_searcher : CrystalMoji::Viterbi::ViterbiSearcher?
    @viterbi_formatter : CrystalMoji::Viterbi::ViterbiFormatter?
    @split : Bool = false
    @token_info_dictionary : CrystalMoji::Dict::TokenInfoDictionary?
    @unknown_dictionary : CrystalMoji::Dict::UnknownDictionary?
    @user_dictionary : CrystalMoji::Dict::UserDictionary?
    @inserted_dictionary : CrystalMoji::Dict::InsertedDictionary?
    @token_factory : CrystalMoji::Viterbi::TokenFactory(T)?
    @dictionary_map : Hash(CrystalMoji::Viterbi::ViterbiNode::Type, CrystalMoji::Dict::Dictionary?) = Hash(CrystalMoji::Viterbi::ViterbiNode::Type, CrystalMoji::Dict::Dictionary?).new

    protected def configure(builder : Builder)
      builder.load_dictionaries

      @token_factory = builder.token_factory
      @token_info_dictionary = builder.token_info_dictionary
      @unknown_dictionary = builder.unknown_dictionary
      @user_dictionary = builder.user_dictionary
      @inserted_dictionary = builder.inserted_dictionary

      @viterbi_builder = CrystalMoji::Viterbi::ViterbiBuilder.new(
        builder.fst.not_nil!,
        @token_info_dictionary.not_nil!,
        @unknown_dictionary.not_nil!,
        @user_dictionary,
        builder.mode
      )

      @viterbi_searcher = CrystalMoji::Viterbi::ViterbiSearcher.new(
        builder.mode,
        builder.connection_costs.not_nil!,
        @unknown_dictionary.not_nil!,
        builder.penalties
      )

      @viterbi_formatter = CrystalMoji::Viterbi::ViterbiFormatter.new(builder.connection_costs.not_nil!)
      @split = builder.split

      init_dictionary_map
    end

    private def init_dictionary_map
      @dictionary_map[CrystalMoji::Viterbi::ViterbiNode::Type::Known] = @token_info_dictionary
      @dictionary_map[CrystalMoji::Viterbi::ViterbiNode::Type::Unknown] = @unknown_dictionary
      @dictionary_map[CrystalMoji::Viterbi::ViterbiNode::Type::User] = @user_dictionary
      @dictionary_map[CrystalMoji::Viterbi::ViterbiNode::Type::Inserted] = @inserted_dictionary
    end

    def tokenize(text : String) : Array(TokenBase)
      create_token_list(text)
    end

    def multi_tokenize(text : String, max_count : Int32, cost_slack : Int32) : Array(Array(T))
      create_multi_token_list(text, max_count, cost_slack)
    end

    def multi_tokenize_n_best(text : String, n : Int32) : Array(Array(T))
      multi_tokenize(text, n, Int32::MAX)
    end

    def multi_tokenize_by_slack(text : String, cost_slack : Int32) : Array(Array(T))
      multi_tokenize(text, Int32::MAX, cost_slack)
    end

    protected def create_token_list(text : String) : Array(T)
      unless @split
        return create_token_list(0, text)
      end

      split_positions = get_split_positions(text)

      if split_positions.empty?
        return create_token_list(0, text)
      end

      result = [] of T
      offset = 0

      split_positions.each do |position|
        result.concat(create_token_list(offset, text[offset..position]))
        offset = position + 1
      end

      if offset < text.size
        result.concat(create_token_list(offset, text[offset..]))
      end

      result
    end

    protected def create_multi_token_list(text : String, max_count : Int32, cost_slack : Int32) : Array(Array(T))
      unless @split
        return convert_multi_search_result_to_list(create_multi_search_result(text, max_count, cost_slack))
      end

      split_positions = get_split_positions(text)

      if split_positions.empty?
        return convert_multi_search_result_to_list(create_multi_search_result(text, max_count, cost_slack))
      end

      results = [] of CrystalMoji::Viterbi::MultiSearchResult
      offset = 0

      split_positions.each do |position|
        results << create_multi_search_result(text[offset..position], max_count, cost_slack)
        offset = position + 1
      end

      if offset < text.size
        results << create_multi_search_result(text[offset..], max_count, cost_slack)
      end

      merger = CrystalMoji::Viterbi::MultiSearchMerger.new(max_count, cost_slack)
      merged_result = merger.merge(results)

      convert_multi_search_result_to_list(merged_result)
    end

    private def convert_multi_search_result_to_list(multi_search_result : CrystalMoji::Viterbi::MultiSearchResult) : Array(Array(T))
      result = [] of Array(T)

      paths = multi_search_result.get_tokenized_results_list

      paths.each do |path|
        tokens = [] of T
        path.each do |node|
          word_id = node.word_id
          if node.type == CrystalMoji::Viterbi::ViterbiNode::Type::Known && word_id == -1 # Do not include BOS/EOS
            next
          end

          token = @token_factory.not_nil!.create_token(
            word_id,
            node.surface,
            node.type,
            node.start_index,
            @dictionary_map[node.type].not_nil!
          ).as(T)
          tokens << token
        end
        result << tokens
      end

      result
    end

    def debug_tokenize(output_stream : IO, text : String)
      lattice = @viterbi_builder.not_nil!.build(text)
      best_path = @viterbi_searcher.not_nil!.search(lattice)

      output_stream.write(
        @viterbi_formatter.not_nil!.format(lattice, best_path).to_slice
      )
      output_stream.flush
    end

    def debug_lattice(output_stream : IO, text : String)
      lattice = @viterbi_builder.not_nil!.build(text)

      output_stream.write(
        @viterbi_formatter.not_nil!.format(lattice).to_slice
      )
      output_stream.flush
    end

    private def get_split_positions(text : String) : Array(Int32)
      split_positions = [] of Int32
      current_position = 0

      while true
        index_of_maru = text.index("。", current_position)
        index_of_ten = text.index("、", current_position)

        if index_of_maru.nil?
          index_of_maru = -1
        end
        if index_of_ten.nil?
          index_of_ten = -1
        end

        position = (if index_of_maru < 0 || index_of_ten < 0
          Math.max(index_of_maru, index_of_ten)
        else
          Math.min(index_of_maru, index_of_ten)
        end).to_i32

        if position >= 0
          split_positions << position
          current_position = position + 1
        else
          break
        end
      end

      split_positions
    end


    private def create_token_list(offset : Int32, text : String) : Array(T)
      result = [] of T

      lattice = @viterbi_builder.not_nil!.build(text)

      best_path = @viterbi_searcher.not_nil!.search(lattice)

      best_path.each do |node|
        word_id = node.word_id
        if node.type == CrystalMoji::Viterbi::ViterbiNode::Type::Known && word_id == -1 # Do not include BOS/EOS
          next
        end

        token = @token_factory.not_nil!.create_token(
          word_id,
          node.surface,
          node.type,
          offset + node.start_index,
          @dictionary_map[node.type].not_nil!
        ).as(T)
        result << token
      end

      result
    end

    private def create_multi_search_result(text : String, max_count : Int32, cost_slack : Int32) : CrystalMoji::Viterbi::MultiSearchResult
      lattice = @viterbi_builder.not_nil!.build(text)
      multi_search_result = @viterbi_searcher.not_nil!.search_multiple(lattice, max_count, cost_slack)
      multi_search_result
    end

    abstract class Builder(T)
      property fst : CrystalMoji::FST::FST?
      property connection_costs : CrystalMoji::Dict::ConnectionCosts?
      property token_info_dictionary : CrystalMoji::Dict::TokenInfoDictionary?
      property unknown_dictionary : CrystalMoji::Dict::UnknownDictionary?
      property character_definitions : CrystalMoji::Dict::CharacterDefinitions?
      property inserted_dictionary : CrystalMoji::Dict::InsertedDictionary?
      property user_dictionary : CrystalMoji::Dict::UserDictionary?
      property mode : CrystalMoji::TokenizerBase::Mode = CrystalMoji::TokenizerBase::Mode::Normal
      property split : Bool = true
      property penalties : Array(Int32) = [] of Int32
      property total_features : Int32 = -1
      property reading_feature : Int32 = -1
      property part_of_speech_feature : Int32 = -1
      property resolver : CrystalMoji::Util::ResourceResolver?
      property token_factory : CrystalMoji::Viterbi::TokenFactory(T)?

      protected def load_dictionaries
        begin
          @fst = CrystalMoji::FST::FST.new_instance(@resolver.not_nil!)
          @connection_costs = ConnectionCosts.new_instance(@resolver.not_nil!)
          @token_info_dictionary = TokenInfoDictionary.new_instance(@resolver.not_nil!)
          @character_definitions = CharacterDefinitions.new_instance(@resolver.not_nil!)
          @unknown_dictionary = UnknownDictionary.new_instance(
            @resolver.not_nil!, @character_definitions.not_nil!, @total_features
          )
          @inserted_dictionary = InsertedDictionary.new(@total_features)
        rescue ex
          raise "Could not load dictionaries: #{ex.message}"
        end
      end

      abstract def build : TokenizerBase

      def user_dictionary(input : IO) : self
        @user_dictionary = CrystalMoji::Dict::UserDictionary.new(input, @total_features, @reading_feature, @part_of_speech_feature)
        self
      end

      def user_dictionary(filename : String) : self
        File.open(filename, "rb") do |file|
          user_dictionary(file)
        end
        self
      end
    end

  end
end
