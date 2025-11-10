require "spec"
require "../src/crystalmoji"

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


def given(input : String) : String
  CrystalMoji::Util::DictionaryEntryLineParser.parse_line(input).join(",")
end


def invert(map : Hash(String, Int32)) : Hash(Int32, String)
  inverted = Hash(Int32, String).new
  map.each do |key, value|
    inverted[value] = key
  end
  inverted
end

def assert_character_categories(category_id_map : Hash(Int32, String), character_definition : CrystalMoji::Dict::CharacterDefinitions, c : Char, categories : Array(String))
  category_ids = character_definition.lookup_categories(c)
  if category_ids.nil?
    categories.should be_empty
    return
  end
  categories.size.should eq category_ids.size

  category_ids.each do |category_id|
    category = category_id_map[category_id]
    categories.should contain(category)
  end
end

def assert_token_surfaces_equals(expected_surfaces : Array(String), actual_tokens : Array(CrystalMoji::TokenBase))
  actual_surfaces = [] of String

  actual_tokens.each do |token|
    actual_surfaces << token.surface
  end

  puts "expected_surfaces: #{expected_surfaces}"
  puts "actual_surfaces: #{actual_surfaces}"
end

def assert_equal_token_feature_lengths(text : String, tokenizer : CrystalMoji::TokenizerBase)
  tokens = tokenizer.tokenize(text)
  lengths = Set(Int32).new
  tokens.each do |token|
    lengths << token.get_all_features_array.size
  end
  lengths.size.should eq(1)
end


def to_string(token : CrystalMoji::Ipadic::Token) : String
  "#{token.surface}\t#{token.get_all_features}"
end

def make_tokenizer(user_dictionary_entry : String) : CrystalMoji::Ipadic::Tokenizer
  buffer = IO::Memory.new(user_dictionary_entry)
  CrystalMoji::Ipadic::Tokenizer::Builder.new
    .user_dictionary(buffer)
    .build
end
