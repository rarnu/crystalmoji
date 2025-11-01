require "../spec_helper"

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

describe Crystalmoji do
  char_def = File.tempfile("kuromoji-chardef-.bin")
  compiler = CrystalMoji::Compile::CharacterDefinitionsCompiler.new(File.open(char_def.path, "w"))
  char_def_stream = File.open("./res/char.def", "r")
  compiler.read_character_definition(char_def_stream, "euc-jp")
  char_def_stream.close

  category_id_map = invert(compiler.make_character_category_map)
  compiler.compile

  input = char_def
  definitions = CrystalMoji::IIO::IntegerArrayIO.read_sparse_array_2d(input)
  mappings = CrystalMoji::IIO::IntegerArrayIO.read_sparse_array_2d(input)
  symbols = CrystalMoji::IIO::StringArrayIO.read_array(input)

  character_definition = CrystalMoji::Dict::CharacterDefinitions.new(definitions, mappings, symbols)

  # case1
  assert_character_categories(category_id_map, character_definition, '\u0000', ["DEFAULT"])
  assert_character_categories(category_id_map, character_definition, '〇', ["SYMBOL", "KANJI", "KANJINUMERIC"])
  assert_character_categories(category_id_map, character_definition, ' ', ["SPACE"])
  assert_character_categories(category_id_map, character_definition, '。', ["SYMBOL"])
  assert_character_categories(category_id_map, character_definition, 'A', ["ALPHA"])
  assert_character_categories(category_id_map, character_definition, 'Ａ', ["ALPHA"])

  # case2
  assert_character_categories(category_id_map, character_definition, '・', ["KATAKANA"])
  character_definition.set_categories('・', ["SYMBOL", "KATAKANA"])
  assert_character_categories(category_id_map, character_definition, '・', ["KATAKANA", "SYMBOL"])
  assert_character_categories(category_id_map, character_definition, '・', ["SYMBOL", "KATAKANA"])
end
