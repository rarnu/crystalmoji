require "./dictionary_entry_base"

module CrystalMoji::Dict
  class GenericDictionaryEntry < DictionaryEntryBase
    getter part_of_speech_features : Array(String)
    getter other_features : Array(String)

    def initialize(builder : Builder)
      super(builder.surface, builder.left_id, builder.right_id, builder.word_cost)
      @part_of_speech_features = builder.part_of_speech_features
      @other_features = builder.other_features
    end

    class Builder
      property surface : String = ""
      property left_id : Int16 = 0_i16
      property right_id : Int16 = 0_i16
      property word_cost : Int16 = 0_i16
      property part_of_speech_features : Array(String) = [] of String
      property other_features : Array(String) = [] of String

      def surface(surface : String) : Builder
        @surface = surface
        self
      end

      def left_id(left_id : Int16) : Builder
        @left_id = left_id
        self
      end

      def right_id(right_id : Int16) : Builder
        @right_id = right_id
        self
      end

      def word_cost(word_cost : Int16) : Builder
        @word_cost = word_cost
        self
      end

      def part_of_speech(pos : Array(String)) : Builder
        @part_of_speech_features = pos
        self
      end

      def features(features : Array(String)) : Builder
        @other_features = features
        self
      end

      def build : GenericDictionaryEntry
        GenericDictionaryEntry.new(self)
      end
    end
  end
end
