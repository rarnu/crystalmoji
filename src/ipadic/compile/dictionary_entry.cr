require "../../core/dict/dictionary_entry_base"
require "../../core/dict/dictionary_field"

module CrystalMoji::Ipadic::Compile
  class DictionaryEntry < CrystalMoji::Dict::DictionaryEntryBase
    class_getter part_of_speech_level_1 : Int32 = 4
    class_getter part_of_speech_level_2 : Int32 = 5
    class_getter part_of_speech_level_3 : Int32 = 6
    class_getter part_of_speech_level_4 : Int32 = 7
    class_getter conjugation_type : Int32 = 8
    class_getter conjugation_form : Int32 = 9
    class_getter base_form : Int32 = 10
    class_getter reading : Int32 = 11
    class_getter pronunciation : Int32 = 12

    class_getter total_features : Int32 = 9
    class_getter reading_feature : Int32 = 7
    class_getter part_of_speech_feature : Int32 = 0

    @pos_level1 : String
    @pos_level2 : String
    @pos_level3 : String
    @pos_level4 : String

    @conjugated_form : String
    @conjugation_type : String

    @base_form : String
    @reading : String
    @pronunciation : String

    def initialize(fields : Array(String))
      super(fields[CrystalMoji::Dict::DictionaryField.surface],
        fields[CrystalMoji::Dict::DictionaryField.left_id].to_i16,
        fields[CrystalMoji::Dict::DictionaryField.right_id].to_i16,
        fields[CrystalMoji::Dict::DictionaryField.word_cost].to_i16)

        @pos_level1 = fields[part_of_speech_level_1]
      @pos_level2 = fields[part_of_speech_level_2]
      @pos_level3 = fields[part_of_speech_level_3]
      @pos_level4 = fields[part_of_speech_level_4]

      @conjugated_form = fields[conjugation_form]
      @conjugation_type = fields[conjugation_type]

      @base_form = field[base_form]
      @reading = field[reading]
      @pronunciation = field[pronunciation]
    end

    def get_part_of_speech_level_1 : String
      @pos_level1
    end

    def get_part_of_speech_level_2 : String
      @pos_level2
    end

    def get_part_of_speech_level_3 : String
      @pos_level3
    end

    def get_part_of_speech_level_4 : String
      @pos_level4
    end

    def get_conjugated_form : String
      @conjugated_form
    end

    def get_conjugation_type : String
      @conjugation_type
    end

    def get_base_form : String
      @base_form
    end

    def get_reading : String
      @reading
    end

    def get_pronunciation : String
      @pronunciation
    end

  end
end
