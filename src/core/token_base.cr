require "./dict/dictionary"
require "./viterbi/viterbi_node"

module CrystalMoji
  abstract class TokenBase
    @@meta_data_size : Int32 = 4

    getter dictionary : CrystalMoji::Dict::Dictionary
    getter word_id : Int32
    getter surface : String
    getter position : Int32
    getter type : CrystalMoji::Viterbi::ViterbiNode::Type

    def initialize(@word_id, @surface, @type, @position, @dictionary)
    end

    def known? : Bool
      @type == CrystalMoji::Viterbi::ViterbiNode::Type::Known
    end

    def user? : Bool
      @type == CrystalMoji::Viterbi::ViterbiNode::Type::User
    end

    def get_all_features : String
      @dictionary.get_all_features(@word_id)
    end

    def get_all_features_array : Array(String)
      @dictionary.get_all_features_array(@word_id)
    end

    def to_s : String
      "Token{surface='#{@surface}', position=#{@position}, type=#{@type}, dictionary=#{@dictionary}, wordId=#{@word_id}}"
    end

    protected def get_feature(feature : Int32) : String
      @dictionary.get_feature(@word_id, feature - @@meta_data_size)
    end

  end
end
