require "../spec_helper"

def make_result(surfaces : Array(Array(String)), cost : Array(Int32)) : CrystalMoji::Viterbi::MultiSearchResult
  ret = CrystalMoji::Viterbi::MultiSearchResult.new
  for i = 0, i < surfaces.size, i += 1 do
    ret.add(make_nodes(surfaces[i]), cost[i])
  end
  ret
end

def make_nodes(surfaces : Array(String)) : Array(CrystalMoji::Viterbi::ViterbiNode)
  ret = Array(CrystalMoji::Viterbi::ViterbiNode).new
  surfaces.each do |s|
    ret << CrystalMoji::Viterbi::ViterbiNode.new(0, s, 0, 0, 0, 0, CrystalMoji::Viterbi::ViterbiNode::Type::Known)
  end
  ret
end

def get_space_separated_tokens(nodes : Array(CrystalMoji::Viterbi::ViterbiNode)) : String
  return "" if nodes.empty?
  sb = String::Builder.new
  sb << nodes[0].surface
  for i = 1, i < nodes.size, i += 1 do
    sb << " "
    sb << nodes[i].surface
  end
  sb.to_s
end

describe Crystalmoji do
  merger = CrystalMoji::Viterbi::MultiSearchMerger.new(3, 8)
  results = Array(CrystalMoji::Viterbi::MultiSearchResult).new

  surfaces1 = [["a", "b"], ["c", "d"], ["e", "f"]]
  costs1 = [1, 2, 3]
  results << make_result(surfaces1, costs1)

  surfaces2 = [["a", "b"], ["c", "d"]]
  costs2 = [1, 2]
  results << make_result(surfaces2, costs2)

  merged_result = merger.merge(results)

  puts "3 => #{merged_result.size}"
  puts "2 => #{merged_result.get_cost(0)}"
  puts "3 => #{merged_result.get_cost(1)}"
  puts "3 => #{merged_result.get_cost(2)}"

  puts "a b a b => #{get_space_separated_tokens(merged_result.get_tokenized_result(0))}"
  puts "c d a b => #{get_space_separated_tokens(merged_result.get_tokenized_result(1))}"
  puts "a b c d => #{get_space_separated_tokens(merged_result.get_tokenized_result(2))}"

end

describe Crystalmoji do
  merger = CrystalMoji::Viterbi::MultiSearchMerger.new(5, 3)
  results = Array(CrystalMoji::Viterbi::MultiSearchResult).new

  surfaces1 = [["a", "b"], ["c", "d"], ["e", "f"]]
  costs1 = [1, 2, 5]
  results << make_result(surfaces1, costs1)

  surfaces2 = [["a", "b"], ["c", "d"]]
  costs2 = [1, 2]
  results << make_result(surfaces2, costs2)

  surfaces3 = [["a", "b"]]
  costs3 = [5]
  results << make_result(surfaces3, costs3)

  merged_result = merger.merge(results)

  puts "4 => #{merged_result.size}"
  puts "7 => #{merged_result.get_cost(0)}"
  puts "8 => #{merged_result.get_cost(1)}"
  puts "8 => #{merged_result.get_cost(2)}"
  puts "9 => #{merged_result.get_cost(3)}"

  puts "a b a b a b => #{get_space_separated_tokens(merged_result.get_tokenized_result(0))}"
  puts "c d a b a b => #{get_space_separated_tokens(merged_result.get_tokenized_result(1))}"
  puts "a b c d a b => #{get_space_separated_tokens(merged_result.get_tokenized_result(2))}"
  puts "c d c d a b => #{get_space_separated_tokens(merged_result.get_tokenized_result(3))}"
end
