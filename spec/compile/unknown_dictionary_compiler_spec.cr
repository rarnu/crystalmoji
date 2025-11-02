require "../spec_helper"

describe Crystalmoji do
  char_def = File.tempfile("kuromoji-chardef-.bin")

  char_def_compiler = CrystalMoji::Compile::CharacterDefinitionsCompiler.new(File.open(char_def.path, "w"))
  char_def_stream = File.open("./res/char.def", "r")

  char_def_compiler.read_character_definition(char_def_stream, "euc-jp")
  char_def_compiler.compile

  category_map = char_def_compiler.make_character_category_map

  unk_def = File.tempfile("kuromoji-unkdef-.bin")

  unk_def_compiler = CrystalMoji::Compile::UnknownDictionaryCompiler.new(category_map, File.open(unk_def.path, "w"))
  unk_def_stream = File.open("./res/unk.def", "r")
  unk_def_compiler.read_unknown_definition(unk_def_stream, "euc-jp")
  unk_def_compiler.compile

  char_def_input = File.open(char_def.path, "r")

  definitions = CrystalMoji::IIO::IntegerArrayIO.read_sparse_array_2d(char_def_input)
  mappings = CrystalMoji::IIO::IntegerArrayIO.read_sparse_array_2d(char_def_input)
  symbols = CrystalMoji::IIO::StringArrayIO.read_array(char_def_input)

  character_definition = CrystalMoji::Dict::CharacterDefinitions.new(definitions, mappings, symbols)

  unk_def_input = File.open(unk_def.path, "r")
  costs = CrystalMoji::IIO::IntegerArrayIO.read_array_2d(unk_def_input)
  references = CrystalMoji::IIO::IntegerArrayIO.read_array_2d(unk_def_input)
  features = CrystalMoji::IIO::StringArrayIO.read_array_2d(unk_def_input)

  unknown_dictionary = CrystalMoji::Dict::UnknownDictionary.new(character_definition, references, costs, features)

  # case
  categories = character_definition.lookup_categories('一')

  # KANJI & KANJINUMERIC
  2.should eq(categories.size)
  categories.should eq([5, 6])

  # KANJI entries
  unknown_dictionary.lookup_word_ids(categories[0]).should eq([2, 3, 4, 5, 6, 7])

  # KANJI feature variety

  unknown_dictionary.get_all_features_array(2).should eq(["名詞", "一般", "*", "*", "*", "*", "*"])
  unknown_dictionary.get_all_features_array(3).should eq(["名詞", "サ変接続", "*", "*", "*", "*", "*"])
  unknown_dictionary.get_all_features_array(4).should eq(["名詞", "固有名詞", "地域", "一般", "*", "*", "*"])
  unknown_dictionary.get_all_features_array(5).should eq(["名詞", "固有名詞", "組織", "*", "*", "*", "*"])
  unknown_dictionary.get_all_features_array(6).should eq(["名詞", "固有名詞", "人名", "一般", "*", "*", "*"])

  # KANJINUMERIC entry
  unknown_dictionary.lookup_word_ids(categories[1]).should eq([29])

  # KANJINUMERIC costs
  unknown_dictionary.get_left_id(29).should eq(1295)
  unknown_dictionary.get_right_id(29).should eq(1295)
  unknown_dictionary.get_word_cost(29).should eq(27473)

  # KANJINUMERIC features
  unknown_dictionary.get_all_features_array(29).should eq(["名詞", "数", "*", "*", "*", "*", "*"])
end

