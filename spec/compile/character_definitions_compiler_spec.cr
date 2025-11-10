require "../spec_helper"

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
