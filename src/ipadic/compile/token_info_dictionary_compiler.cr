require "../../core/compile/token_info_dictionary_compiler_base"
require "./dictionary_entry"
require "../../core/dict/generic_dictionary_entry"

module CrystalMoji::Ipadic::Compile

  class TokenInfoDictionaryCompiler < CrystalMoji::Compile::TokenInfoDictionaryCompilerBase(DictionaryEntry)

    def initialize(encoding : String)
      super(encoding)
    end

    def parse(line : String) : DictionaryEntry
      fields = DictionaryEntryLineParser.parse_line(line)
      DictionaryEntry.new(fields)
    end

    def make_generic_dictionary_entry(entry : DictionaryEntry) : CrystalMoji::Dict::GenericDictionaryEntry
      pos = make_part_of_speech_features(entry)
      features = make_other_features(entry)
      GenericDictionaryEntry::Builder.new
        .surface(entry.surface)
        .left_id(entry.left_id)
        .right_id(entry.right_id)
        .word_cost(entry.word_cost)
        .part_of_speech_feature(pos)
        .features(features)
        .build
    end

    def make_part_of_speech_features(enty : DictionaryEntry) : Array(String)
      pos_features = Array(String).new
      pos_features << entry.get_part_of_speech_level_1
      pos_features << entry.get_part_of_speech_level_2
      pos_features << entry.get_part_of_speech_level_3
      pos_features << entry.get_part_of_speech_level_4

      pos_features << entry.get_conjugation_type
      pos_features << entry.get_conjugated_form
      pos_features
    end

    def make_other_features(entry : DictionaryEntry) : Array(String)
      other_features = Array(String).new

      other_features << entry.get_base_form
      other_features << entry.get_reading
      other_features << entry.get_pronunciation

      other_features
    end

  end
end
