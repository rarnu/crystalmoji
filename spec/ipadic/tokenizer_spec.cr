require "../spec_helper"

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

tokenizer = CrystalMoji::Ipadic::Tokenizer.new


describe Crystalmoji do
  input = "スペースステーションに行きます。うたがわしい。"
  surfaces = ["スペース", "ステーション", "に", "行き", "ます", "。", "うたがわしい", "。"]

  assert_token_surfaces_equals(surfaces, tokenizer.tokenize(input))
end

describe Crystalmoji do
  input = "スペースステーションに行きます。うたがわしい。"
  token_lists = tokenizer.multi_tokenize(input, 20, 100000)
  puts "token_lists.size = #{token_lists.size}"  # 20

  token_lists.each do |tokens|
    sb = String::Builder.new
    tokens.each do |token|
      sb << token.surface
    end
    input.should eq(sb.to_s)
  end

  surfaces = ["スペース", "ステーション", "に", "行き", "ます", "。", "うたがわしい", "。"]
  assert_token_surfaces_equals(surfaces, token_lists[0])
end

describe Crystalmoji do
  input = "難しい。。。"
  token_lists = tokenizer.multi_tokenize(input, 2, 100000)
  surfaces = ["難しい", "。", "。", "。"]
  assert_token_surfaces_equals(surfaces, token_lists[0])
end

describe Crystalmoji do
  input = "スペースステーション"
  token_lists = tokenizer.multi_tokenize_n_best(input, 100)
  puts "token_lists.size = #{token_lists.size}" # 9
end

describe Crystalmoji do
  input = "バスできた。"
  token_lists = tokenizer.multi_tokenize_by_slack(input, Int32::MAX)
  puts "token_lists.size = #{token_lists.size}" # 4620
end

describe Crystalmoji do
  input = ""
  token_lists = tokenizer.multi_tokenize(input, 10, Int32::MAX)
  puts "token_lists.size = #{token_lists.size}" # 1
end

describe Crystalmoji do
  tokens = tokenizer.tokenize("寿司が食べたいです。")
  puts "tokens.size = #{tokens.size}" #6

  puts "0 => #{tokens[0].get_reading}"  # スシ
  puts "1 => #{tokens[1].get_reading}"  # ガ
  puts "2 => #{tokens[2].get_reading}"  # タベ
  puts "3 => #{tokens[3].get_reading}"  # タイ
  puts "4 => #{tokens[4].get_reading}"  # デス
  puts "5 => #{tokens[5].get_reading}"  # 。
end

describe Crystalmoji do
  tokens = tokenizer.tokenize("郵税")
  puts "reading => #{tokens[0].get_reading}" # ユウゼイ
end

describe Crystalmoji do
  tokens = tokenizer.tokenize("お寿司が食べたい。")
  puts "tokens.size = #{tokens.size}" # 6
  puts "3 => #{tokens[3].surface}" # 食べ
  puts "3 => #{tokens[3].get_base_form}" # 食べる
end

describe Crystalmoji do
  tokens = tokenizer.tokenize("アティリカ株式会社")
  puts "tokens.size = #{tokens.size}" # 2
  puts "known = #{tokens[0].known?}"  # false
  puts "base_form => #{tokens[0].get_base_form}" # *
  puts "known = #{tokens[1].known?}"  # true
  puts "1 => #{tokens[1].get_base_form}" # 株式会社
end

describe Crystalmoji do
  tokens = tokenizer.tokenize("やぼったい")
  puts "tokens.size = #{tokens.size}" # 1
  puts "surface = #{tokens[0].surface}" # やぼったい
end

describe Crystalmoji do
  tokens = tokenizer.tokenize("突き通しゃ")
  puts "tokens.size = #{tokens.size}" # 1
  puts "surface = #{tokens[0].surface}" # 突き通しゃ
end

describe Crystalmoji do
  tokens = tokenizer.tokenize("お寿司が食べたい！")
  pronunciations = ["オ", "スシ", "ガ", "タベ", "タイ", "！"]
  tokens.size.should eq(pronunciations.size)

  for i = 0, i < tokens.size, i += 1 do
    pronunciations[i].should eq(tokens[i].get_pronunciation)
  end

  conjugation_forms = ["*", "*", "*", "連用形", "基本形", "*"]

  for i = 0, i < tokens.size, i += 1 do
    conjugation_forms[i].should eq(tokens[i].get_conjugation_form)
  end

  conjugation_types = ["*", "*", "*", "一段", "特殊・タイ", "*"]

  for i = 0, i < tokens.size, i += 1 do
    conjugation_types[i].should eq(tokens[i].get_conjugation_type)
  end

  pos_level1 = ["接頭詞", "名詞", "助詞", "動詞", "助動詞", "記号"]

  for i = 0, i < tokens.size, i += 1 do
    pos_level1[i].should eq(tokens[i].get_part_of_speech_level1)
  end

  pos_level2 = ["名詞接続", "一般", "格助詞", "自立", "*", "一般"]

  for i = 0, i < tokens.size, i += 1 do
    pos_level2[i].should eq(tokens[i].get_part_of_speech_level2)
  end

  pos_level3 = ["*", "*", "一般", "*", "*", "*"]

  for i = 0, i < tokens.size, i += 1 do
    pos_level3[i].should eq(tokens[i].get_part_of_speech_level3)
  end

  pos_level4 = ["*", "*", "*", "*", "*", "*"]

  for i = 0, i < tokens.size, i += 1 do
    pos_level4[i].should eq(tokens[i].get_part_of_speech_level4)
  end
end

describe Crystalmoji do
  input = "シニアソフトウェアエンジニアを探しています"
  custom_tokenizer = CrystalMoji::Ipadic::Tokenizer::Builder.new
    .mode(CrystalMoji::Ipadic::Tokenizer::Mode::Search)
    .kanji_penalty(3, 10000)
    .other_penalty(Int32::MAX, 0)
    .build

  expected1 = ["シニアソフトウェアエンジニア", "を", "探し", "て", "い", "ます"]
  assert_token_surfaces_equals(expected1, custom_tokenizer.tokenize(input))

  search_tokenizer = CrystalMoji::Ipadic::Tokenizer::Builder.new
    .mode(CrystalMoji::Ipadic::Tokenizer::Mode::Search)
    .build

  expected2 = ["シニア", "ソフトウェア", "エンジニア", "を", "探し", "て", "い", "ます"]
  assert_token_surfaces_equals(expected2, search_tokenizer.tokenize(input))
end

describe Crystalmoji do
  default_tokenizer = CrystalMoji::Ipadic::Tokenizer.new
  nakakuro_splitting_tokenizer = CrystalMoji::Ipadic::Tokenizer::Builder.new
    .split_on_nakaguro(true)
    .build
  input = "ラレ・プールカリムの音楽が好き。"
  assert_token_surfaces_equals(["ラレ・プールカリム", "の", "音楽", "が", "好き", "。"], default_tokenizer.tokenize(input))

  assert_token_surfaces_equals(["ラレ", "・", "プールカリム", "の", "音楽", "が", "好き", "。"], nakakuro_splitting_tokenizer.tokenize(input))

end

describe Crystalmoji do
  tokenizer = CrystalMoji::Ipadic::Tokenizer.new
  input = "寿司が食べたいです。"
  tokens = tokenizer.tokenize(input)

  puts to_string(tokens[0]) # 寿司\t名詞,一般,*,*,*,*,寿司,スシ,スシ
  puts to_string(tokens[1]) # が\t助詞,格助詞,一般,*,*,*,が,ガ,ガ
  puts to_string(tokens[2]) # 食べ\t動詞,自立,*,*,一段,連用形,食べる,タベ,タベ
  puts to_string(tokens[3]) # たい\t助動詞,*,*,*,特殊・タイ,基本形,たい,タイ,タイ
  puts to_string(tokens[4]) # です\t助動詞,*,*,*,特殊・デス,基本形,です,デス,デス

end

describe Crystalmoji do
  input = "＼ｍ"
  tokenizer = CrystalMoji::Ipadic::Tokenizer.new
  assert_token_surfaces_equals(["＼", "ｍ"], tokenizer.tokenize(input))
end

describe Crystalmoji do
  user_dictionary = "gsf,gsf,ジーエスーエフ,カスタム名詞\n"
  mm = IO::Memory.new
  mm << user_dictionary
  tokenizer = CrystalMoji::Ipadic::Tokenizer::Builder.new
    .user_dictionary(mm)
    .build
  assert_equal_token_feature_lengths("ahgsfdajhgsfdこの丘はアクロポリスと呼ばれている。", tokenizer)
end


describe Crystalmoji do
  input = "僕の鼻はちょっと\r\n長いよ。"
  assert_token_surfaces_equals(["僕", "の", "鼻", "は", "ちょっと", "\r", "\n", "長い", "よ", "。"], tokenizer.tokenize(input))
end
