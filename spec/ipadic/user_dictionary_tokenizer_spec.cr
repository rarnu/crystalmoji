require "../spec_helper"

describe Crystalmoji do
  user_dictionary = "iPhone4 S,iPhone4 S,iPhone4 S,カスタム名詞"
  tokenizer = make_tokenizer(user_dictionary)
  input = "iPhone4 S"
  assert_token_surfaces_equals(["iPhone4 S"], tokenizer.tokenize(input))
end

describe Crystalmoji do
  entry = "関西国際空港,関西 国際 空,カンサイ コクサイクウコウ,カスタム名詞"
  make_tokenizer(entry)
rescue e
  puts e
end

describe Crystalmoji do
  user_dictionary = "クロ,クロ,クロ,カスタム名詞"
  tokenizer = make_tokenizer(user_dictionary)
  input = "アクロポリス"
  assert_token_surfaces_equals(["ア", "クロ", "ポリス"], tokenizer.tokenize(input))
end

describe Crystalmoji do
  input = "シロクロ"
  surfaces = ["シロ", "クロ"]
  user_dictionary = "クロ,クロ,クロ,カスタム名詞\n真救世主,真救世主,シンキュウセイシュ,カスタム名詞\n真救世主伝説,真救世主伝説,シンキュウセイシュデンセツ,カスタム名詞\n北斗の拳,北斗の拳,ホクトノケン,カスタム名詞"
  tokenizer = make_tokenizer(user_dictionary)
  tokens = tokenizer.tokenize(input)
  puts "length = #{tokens.size}" # 2
  token = tokens[1]
  actual = token.surface + "\t" + token.get_all_features
  puts actual # クロ\tカスタム名詞,*,*,*,*,*,*,クロ,*

end

describe Crystalmoji do
  user_dictionary = "クロ,クロ,クロ,カスタム名詞"
  tokenizer = make_tokenizer(user_dictionary)
  input = "この丘はアクロポリスと呼ばれている。"
  assert_token_surfaces_equals(["この", "丘", "は", "ア", "クロ", "ポリス", "と", "呼ば", "れ", "て", "いる", "。"], tokenizer.tokenize(input))
end

describe Crystalmoji do
  user_dictionary = "クロ,クロ,クロ,カスタム名詞"
  tokenizer = make_tokenizer(user_dictionary)
  input = "アクロア"
  surfaces = ["ア", "クロ", "ア"]
  features = ["*,*,*,*,*,*,*,*,*", "カスタム名詞,*,*,*,*,*,*,クロ,*", "*,*,*,*,*,*,*,*,*"]
  tokens = tokenizer.tokenize(input)
  for i = 0, i < tokens.size, i += 1 do
    surfaces[i].should eq(tokens[i].surface)
    features[i].should eq(tokens[i].get_all_features)
  end

end

describe Crystalmoji do
  user_dictionary = "クロ,クロ,クロ,カスタム名詞"
  tokenizer = make_tokenizer(user_dictionary)
  input = "この丘の名前はアクロアだ。"
  surfaces = ["この", "丘", "の", "名前", "は", "ア", "クロ", "ア", "だ", "。"]
  features = ["連体詞,*,*,*,*,*,この,コノ,コノ", "名詞,一般,*,*,*,*,丘,オカ,オカ", "助詞,連体化,*,*,*,*,の,ノ,ノ", "名詞,一般,*,*,*,*,名前,ナマエ,ナマエ", "助詞,係助詞,*,*,*,*,は,ハ,ワ", "*,*,*,*,*,*,*,*,*", "カスタム名詞,*,*,*,*,*,*,クロ,*", "*,*,*,*,*,*,*,*,*", "助動詞,*,*,*,特殊・ダ,基本形,だ,ダ,ダ", "記号,句点,*,*,*,*,。,。,。"]
  tokens = tokenizer.tokenize(input)
  for i = 0, i < tokens.size, i += 1 do
    surfaces[i].should eq(tokens[i].surface)
    features[i].should eq(tokens[i].get_all_features)
  end
end

describe Crystalmoji do
  user_dictionary = "真救世主,真救世主,シンキュウセイシュ,カスタム名詞"
  tokenizer = make_tokenizer(user_dictionary)
  input = "真救世主伝説"
  puts tokenizer.tokenize(input)[0].get_reading # シンキュウセイシュ
end

describe Crystalmoji do
  user_dictionary = "真救世主伝説,真救世主伝説,シンキュウセイシュデンセツ,カスタム名詞"
  tokenizer = make_tokenizer(user_dictionary)
  input = "真救世主伝説"
  puts tokenizer.tokenize(input)[0].get_reading # シンキュウセイシュデンセツ
end

describe Crystalmoji do
  user_dictionary = "クロ,クロ,クロ,カスタム名詞\n真救世主,真救世主,シンキュウセイシュ,カスタム名詞\n真救世主伝説,真救世主伝説,シンキュウセイシュデンセツ,カスタム名詞\n北斗の拳,北斗の拳,ホクトノケン,カスタム名詞"
  input = "北斗の拳は真救世主伝説の名曲である。"
  tokenizer = make_tokenizer(user_dictionary)
  tokens = tokenizer.tokenize(input)
  expected_readings = ["ホクトノケン", "ハ", "シンキュウセイシュデンセツ", "ノ", "メイキョク", "デ", "アル", "。"]
  for i = 0, i < tokens.size, i += 1 do
    expected_readings[i].should eq(tokens[i].get_reading)
  end
end

describe Crystalmoji do
  user_dictionary = "竜宮の乙姫の元結の切り外し,竜宮の乙姫の元結の切り外し,リュウグウノオトヒメノモトユイノキリハズシ,カスタム名詞"
  tokenizer = make_tokenizer(user_dictionary)
  input = "竜宮の乙姫の元結の切り外し"
  puts tokenizer.tokenize(input)[0].get_reading # リュウグウノオトヒメノモトユイノキリハズシ
end

describe Crystalmoji do
  user_dictionary = "マルキ・ド・サドの演出のもとにシャラントン精神病院患者たちによって演じられたジャン＝ポール・マラーの迫害と暗殺,マルキ・ド・サドの演出のもとにシャラントン精神病院患者たちによって演じられたジャン＝ポール・マラーの迫害と暗殺,マルキ・ド・サドノエンシュツノモトニシャラントンセイシンビョウインカンジャタチニヨッテエンジラレタジャン＝ポール・マラーノハクガイトアンサツ,カスタム名詞"
  tokenizer = make_tokenizer(user_dictionary)
  input = "マルキ・ド・サドの演出のもとにシャラントン精神病院患者たちによって演じられたジャン＝ポール・マラーの迫害と暗殺"
  puts tokenizer.tokenize(input)[0].get_reading # マルキ・ド・サドノエンシュツノモトニシャラントンセイシンビョウインカンジャタチニヨッテエンジラレタジャン＝ポール・マラーノハクガイトアンサツ
end

describe Crystalmoji do
  user_dictionary = "クリ,クリ,クリ,カスタム名詞\nチャン,チャン,チャン,カスタム名詞\nリスチャン,リスチャン,リスチャン,カスタム名詞"
  input = "クリスチャンは寿司が大好きです。"
  tokenizer = make_tokenizer(user_dictionary)
  tokens = tokenizer.tokenize(input)
  assert_token_surfaces_equals(["ク", "リスチャン", "は", "寿司", "が", "大好き", "です", "。"], tokens)
end

describe Crystalmoji do
  user_dictionary = "関西国際空港,関西国際空港,かんさいこくさいくうこう,カスタム施設\n関西,関西,かんさい,カスタム地名"
  input = "関西国際医療センター"
  tokenizer = make_tokenizer(user_dictionary)
  tokens = tokenizer.tokenize(input)
  puts tokens[0].surface # 関西
  puts tokens[0].get_part_of_speech_level1 # カスタム地名
end

describe Crystalmoji do
  user_dictionary = "引,引,引,カスタム品詞\n"
  tokenizer = make_tokenizer(user_dictionary)
  assert_token_surfaces_equals(["引", "く", "。"], tokenizer.tokenize("引く。"))
end

describe Crystalmoji do
  user_dictionary = "日本経済新聞,日本 経済 新聞,ニホン ケイザイ シンブン,カスタム名詞\n渡部,1290,1290,5900,カスタム名詞,固有名詞,人名,姓,*,*,渡部,ワタナベ,ワタナベ\n"
  tokenizer = make_tokenizer(user_dictionary)
  input = "渡部さんは日本経済新聞社に勤めている。"
  surfaces = ["渡部", "さん", "は", "日本", "経済", "新聞", "社", "に", "勤め", "て", "いる", "。"]
  features = [
            "カスタム名詞,固有名詞,人名,姓,*,*,渡部,ワタナベ,ワタナベ",
            "名詞,接尾,人名,*,*,*,さん,サン,サン",
            "助詞,係助詞,*,*,*,*,は,ハ,ワ",
            "カスタム名詞,*,*,*,*,*,*,ニホン,*",
            "カスタム名詞,*,*,*,*,*,*,ケイザイ,*",
            "カスタム名詞,*,*,*,*,*,*,シンブン,*",
            "名詞,一般,*,*,*,*,社,シャ,シャ",
            "助詞,格助詞,一般,*,*,*,に,ニ,ニ",
            "動詞,自立,*,*,一段,連用形,勤める,ツトメ,ツトメ",
            "助詞,接続助詞,*,*,*,*,て,テ,テ",
            "動詞,非自立,*,*,一段,基本形,いる,イル,イル",
            "記号,句点,*,*,*,*,。,。,。"
  ]
  tokens = tokenizer.tokenize(input)
  for i = 0, i < tokens.size, i += 1 do
    surfaces[i].should eq(tokens[i].surface)
    features[i].should eq(tokens[i].get_all_features)
  end
end
