require "../core/tokenizer_base"
require "../core/viterbi/**"
require "../core/dict/dictionary"
require "./token"
require "../core/util/simple_resource_resolver"

module CrystalMoji::Ipadic
  class Tokenizer < CrystalMoji::TokenizerBase(Token)

    def initialize(builder : Builder)

      configure(builder)
    end

    def self.new() : Tokenizer
      builder = Builder.new
      Tokenizer.new(builder)
    end

    def tokenize(text : String) : Array(Token)
      create_token_list(text)
    end

    class Builder < TokenizerBase::Builder(Token)
      class_property default_kanji_length_threshold : Int32 = 2
      class_property default_other_length_threshold : Int32 = 7
      class_property default_kanji_penalty : Int32 = 3000
      class_property default_other_penalty : Int32 = 1700

      property kanji_penalty_length_threshold : Int32 = default_kanji_length_threshold
      property kanji_penalty : Int32 = default_kanji_penalty
      property other_penalty_length_threshold : Int32 = default_other_length_threshold
      property other_penalty : Int32 = default_other_penalty
      property nakaguro_split : Bool = false

      # Creates a default builder
      def initialize
        super()

        @total_features = CrystalMoji::Ipadic::Compile::DictionaryEntry.total_features
        @reading_feature = CrystalMoji::Ipadic::Compile::DictionaryEntry.reading_feature
        @part_of_speech_feature = CrystalMoji::Ipadic::Compile::DictionaryEntry.part_of_speech_feature

        @token_factory = InternalTokenFactory(Token).new
      end

      class InternalTokenFactory(Token)
        include CrystalMoji::Viterbi::TokenFactory(Token)

        def create_token(word_id : Int32, surface : String, type : CrystalMoji::Viterbi::ViterbiNode::Type, position : Int32, dictionary : CrystalMoji::Dict::Dictionary) : Token
          Token.new(word_id, surface, type, position, dictionary)
        end
      end

      # Sets the tokenization mode
      def mode(mode : TokenizerBase::Mode) : Builder
        @mode = mode
        self
      end

      # Sets a custom kanji penalty
      def kanji_penalty(length_threshold : Int32, penalty : Int32) : Builder
        @kanji_penalty_length_threshold = length_threshold
        @kanji_penalty = penalty
        self
      end

      # Sets a custom non-kanji penalty
      def other_penalty(length_threshold : Int32, penalty : Int32) : Builder
        @other_penalty_length_threshold = length_threshold
        @other_penalty = penalty
        self
      end

      # Predicate that splits unknown words on the middle dot character (U+30FB KATAKANA MIDDLE DOT)
      def split_on_nakaguro(split : Bool) : Builder
        @nakaguro_split = split
        self
      end

      # Creates the custom tokenizer instance
      def build : Tokenizer
        Tokenizer.new(self)
      end

      protected def load_dictionaries
        @penalties = [
          @kanji_penalty_length_threshold,
          @kanji_penalty,
          @other_penalty_length_threshold,
          @other_penalty,
        ]

        @resolver = CrystalMoji::Util::SimpleResourceResolver.new

        begin
          @fst = CrystalMoji::FST::FST.new_instance(@resolver.not_nil!)
          @connection_costs = CrystalMoji::Dict::ConnectionCosts.new_instance(@resolver.not_nil!)
          @token_info_dictionary = CrystalMoji::Dict::TokenInfoDictionary.new_instance(@resolver.not_nil!)
          @character_definitions = CrystalMoji::Dict::CharacterDefinitions.new_instance(@resolver.not_nil!)

          if @nakaguro_split
            @character_definitions.not_nil!.set_categories('・', ["SYMBOL"])
          end

          @unknown_dictionary = CrystalMoji::Dict::UnknownDictionary.new_instance(
            @resolver.not_nil!, @character_definitions.not_nil!, @total_features
          )
          @inserted_dictionary = CrystalMoji::Dict::InsertedDictionary.new(@total_features)
        rescue ex
          raise "Could not load dictionaries: #{ex.message}"
        end
      end
    end
  end

end
