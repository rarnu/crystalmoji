require "../core/token_base"
require "../core/viterbi/viterbi_node"
require "../core/dict/dictionary"
require "./compile/dictionary_entry"

module CrystalMoji::Ipadic

  class Token < CrystalMoji::TokenBase

    @@hiragana = "ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑをん"

    @@katakana = "ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱヲンヴヵヶ"

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

    def furigana : String
      kata_kana = to_katakana(surface)
      if kata_kana == to_katakana(self.get_reading) || self.get_reading == "*"
        return surface
      end
      s1_ori = surface
      s1 = to_hiragana(surface)
      h2 = to_hiragana(self.get_reading)
      s2 = ""
      head = ""
      tail = ""
      while true
        s2 = h2
        if s1[0] != s2[0]
          break
        end
        head += s1[0]
        s1_ori = s1_ori.lchop
        s1 = s1.lchop
        h2 = s2.lchop
      end
      while s1[s1.size - 1] == s2[s2.size - 1]
        tail = s1[s1.size - 1] + tail
        s1_ori = s1_ori.rchop
        s1 = s1.rchop
        s2 = s2.rchop
      end


      "#{head}[#{s1_ori}(#{s2})]#{tail}"
    end


    private def to_katakana(s : String) : String
      str = ""
      s.each_char do |c|
        idx = @@hiragana.index(c)
        str += idx.nil? ? c : @@katakana[idx]
      end
      str
    end

    private def to_hiragana(s : String) : String
      str = ""
      s.each_char do |c|
        idx = @@katakana.index(c)
        str += idx.nil? ? c : @@hiragana[idx]
      end
      str
    end
  end
end

