require "../spec_helper"


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
