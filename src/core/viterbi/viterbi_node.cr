module CrystalMoji::Viterbi
  class ViterbiNode
    enum Type
      Known
      Unknown
      User
      Inserted
    end

    getter word_id : Int32
    getter surface : String
    getter left_id : Int32
    getter right_id : Int32
    getter word_cost : Int32
    getter start_index : Int32
    getter type : Type

    property path_cost : Int32 = 0
    property left_node : ViterbiNode? = nil


    def initialize(@word_id, @surface, @left_id, @right_id, @word_cost, @start_index, @type)
    end

    def self.from_dict(word_id : Int32, word : String, dictionary : CrystalMoji::Dict::Dictionary, start_index : Int32, type : Type)
      ViterbiNode.new(word_id, word, dictionary.get_left_id(word_id), dictionary.get_right_id(word_id), dictionary.get_word_cost(word_id), start_index, type)
    end
  end
end
