require "./dictionary_entry_line_parser"
require "../dict/generic_dictionary_entry"

module CrystalMoji::Util
  class UnknownDictionaryEntryParser < DictionaryEntryLineParser
    def parse(entry : String) : CrystalMoji::Dict::GenericDictionaryEntry
      fields = CrystalMoji::Util::DictionaryEntryLineParser.parse_line(entry)
      surface = fields[0]
      left_id = fields[1].to_i16
      right_id = fields[2].to_i16
      word_cost = fields[3].to_i16

      pos = Array(String).new
      pos.concat(fields[4, 6])

      features = Array(String).new
      features.concat(fields[10, fields.size - 1])

      dictionary_entry = CrystalMoji::Dict::GenericDictionaryEntry::Builder.new
        .surface(surface)
        .left_id(left_id)
        .right_id(right_id)
        .word_cost(word_cost)
        .part_of_speech(pos)
        .features(features)
        .build

      return dictionary_entry
    end
  end
end

