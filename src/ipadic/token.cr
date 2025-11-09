require "../core/token_base"
require "../core/viterbi/viterbi_node"
require "../core/dict/dictionary"
require "./compile/dictionary_entry"

module CrystalMoji::Ipadic

  class Token < CrystalMoji::TokenBase

    def initialize(wordId : Int32, surface : String, type : CrystalMoji::Viterbi::ViterbiNode::Type, position : Int32, dictionary : CrystalMoji::Dict::Dictionary)
      super(wordId, surface, type, position, dictionary)
    end

    def get_part_of_speech_level1 : String
      get_feature(CrystalMoji::Ipadic::Compile::DictionaryEntry.part_of_speech_level_1)
    end

    def get_part_of_speech_level2 : String
      get_feature(CrystalMoji::Ipadic::Compile::DictionaryEntry.part_of_speech_level_2)
    end

    def get_part_of_speech_level3 : String
      get_feature(CrystalMoji::Ipadic::Compile::DictionaryEntry.part_of_speech_level_3)
    end

    def get_part_of_speech_level4 : String
      get_feature(CrystalMoji::Ipadic::Compile::DictionaryEntry.part_of_speech_level_4)
    end

    def get_conjugation_type : String
      get_feature(CrystalMoji::Ipadic::Compile::DictionaryEntry.conjugation_type)
    end

    def get_conjugation_form : String
      get_feature(CrystalMoji::Ipadic::Compile::DictionaryEntry.conjugation_form)
    end

    def get_base_form : String
      get_feature(CrystalMoji::Ipadic::Compile::DictionaryEntry.base_form)
    end

    def get_reading : String
      get_feature(CrystalMoji::Ipadic::Compile::DictionaryEntry.reading)
    end

    def get_pronunciation : String
      get_feature(CrystalMoji::Ipadic::Compile::DictionaryEntry.pronunciation)
    end


  end

end
