require "./viterbi_node"
require "../dict/dictionary"

module CrystalMoji::Viterbi
  module TokenFactory(T)
    abstract def create_token(word_id : Int32, surface : String, type : CrystalMoji::Viterbi::ViterbiNode::Type, position : Int32, dictionary : CrystalMoji::Dict::Dictionary) : T
  end
end
