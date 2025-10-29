require "../spec_helper"
require "uuid"

describe Crystalmoji do
  trie = CrystalMoji::Trie::PatriciaTrie(String).new
  trie["a"] = "a"
  trie["b"] = "b"
  trie["ab"] = "ab"
  trie["bac"] = "bac"

  puts "a = #{"a" == trie["a"]}"
  puts "bac" == trie["bac"]
  puts "b" == trie["b"]
  puts "ab" == trie["ab"]

  puts trie["nonexistant"].nil?
end

describe Crystalmoji do
  trie = CrystalMoji::Trie::PatriciaTrie(String).new
  trie["寿司"] = "sushi"
  trie["刺身"] = "sashimi"

  puts "sushi = #{"sushi" == trie["寿司"]}"
  puts "sashimi" == trie["刺身"]
end

describe Crystalmoji do
  trie = CrystalMoji::Trie::PatriciaTrie(String).new
  trie["null"] = nil
  puts "trie[null] = #{trie["null"].nil?}"
end

describe Crystalmoji do
  randoms = Array(String).new
  10000.times do |_|
    randoms << UUID.v4.to_s
  end
  trie = CrystalMoji::Trie::PatriciaTrie(String).new
  randoms.each do |random|
    trie[random] = random
  end
  randoms.each do |random|
    random.should eq(trie[random])
    trie.has_key?(random).should be_true
  end
end

describe Crystalmoji do
  randoms = Hash(String, String).new
  1000.times do |_|
    random = UUID.v4.to_s
    randoms[random] = random
  end
  trie = CrystalMoji::Trie::PatriciaTrie(String).new
  trie << randoms

  randoms.each do |k, v|
    v.should eq(trie[k])
    trie.has_key?(k).should be_true
  end
end

describe Crystalmoji do
  long_movie_title = "マルキ・ド・サドの演出のもとにシャラントン精神病院患者たちによって演じられたジャン＝ポール・マラーの迫害と暗殺"
  trie = CrystalMoji::Trie::PatriciaTrie(String).new
  trie[long_movie_title] = "found it"
  "found it".should eq(trie[long_movie_title])
end

describe Crystalmoji do
  trie = CrystalMoji::Trie::PatriciaTrie(String).new
  puts "is_empty = #{trie.empty?}"
  trie["hello"] = "world"
  puts "is_empty = #{trie.empty?}"
end

describe Crystalmoji do
  trie = CrystalMoji::Trie::PatriciaTrie(String).new
  puts "is_empty = #{trie.empty?}"
  trie[""] = "i am empty bottle of beer!"
  puts "is_empty = #{trie.empty?}"
  puts "i am empty bottle of beer!" == trie[""]
  trie[""] = "...and i'm an empty bottle of sake"
  puts "...and i'm an empty bottle of sake" == trie[""]
end

describe Crystalmoji do
  trie = CrystalMoji::Trie::PatriciaTrie(String).new
  puts "size = #{trie.size}"
  trie["hello"] = "world"
  puts "is_empty = #{trie.empty?}"
  trie.clear
  puts "is_empty = #{trie.empty?}"
  puts "size = #{trie.size}"
end

describe Crystalmoji do
  trie = CrystalMoji::Trie::PatriciaTrie(String).new
  trie["寿司"] = "sushi"
  trie["刺身"] = "sashimi"
  trie["そば"] = "soba"
  trie["ラーメン"] = "ramen"

  puts "trie.keys.size = #{trie.keys.size}"
  puts trie.keys.contains_all?(["寿司", "そば", "ラーメン", "刺身"])

  puts "trie.values.size = #{trie.values.size}"
  puts trie.values.contains_all?(["sushi", "soba", "ramen", "sashimi"])
end

describe Crystalmoji do
  trie = CrystalMoji::Trie::PatriciaTrie(String).new
  trie["new"] = "no error"
  puts trie.contains_key_prefix?("new\na")
  puts trie.contains_key_prefix?("\n")
  puts trie.contains_key_prefix?("\t")
end

describe Crystalmoji do
  trie = CrystalMoji::Trie::PatriciaTrie(String).new
  tokyo_places = [
    "Hachiōji",
    "Tachikawa",
    "Musashino",
    "Mitaka",
    "Ōme",
    "Fuchū",
    "Akishima",
    "Chōfu",
    "Machida",
    "Koganei",
    "Kodaira",
    "Hino",
    "Higashimurayama",
    "Kokubunji",
    "Kunitachi",
    "Fussa",
    "Komae",
    "Higashiyamato",
    "Kiyose",
    "Higashikurume",
    "Musashimurayama",
    "Tama",
    "Inagi",
    "Hamura",
    "Akiruno",
    "Nishitōkyō",
  ]

  tokyo_places.each do |place|
    trie[place] = place
  end

  puts "K => #{trie.contains_key_prefix?("K")}"
  puts "Ko => #{trie.contains_key_prefix?("Ko")}"
  puts "Kod => #{trie.contains_key_prefix?("Kod")}"
  puts "Koda => #{trie.contains_key_prefix?("Koda")}"
  puts "Kodai => #{trie.contains_key_prefix?("Kodai")}"
  puts "Kodair => #{trie.contains_key_prefix?("Kodair")}"
  puts "Kodaira => #{trie.contains_key_prefix?("Kodaira")}"
  puts "Kodaira_ => #{trie.contains_key_prefix?("Kodaira ")}"
  puts "Kodaira__ => #{trie.contains_key_prefix?("Kodaira  ")}"

  puts "Kodaira => #{trie["Kodaira"].nil?}"
  puts "fu => #{trie.contains_key_prefix?("fu")}"
  puts "Fu => #{trie.contains_key_prefix?("Fu")}"
  puts "Fus => #{trie.contains_key_prefix?("Fus")}"
end

describe Crystalmoji do
  trie = CrystalMoji::Trie::PatriciaTrie(String).new

  terms = [
    "お寿司", "sushi",
    "美味しい", "tasty",
    "日本", "japan",
    "だと思います", "i think",
    "料理", "food",
    "日本料理", "japanese food",
    "一番", "first and foremost",
  ]

  for i = 0, i < terms.size, i += 2 do
    trie[terms[i]] = terms[i + 1]
  end


  text = "日本料理の中で、一番美味しいのはお寿司だと思います。すぐ日本に帰りたいです。"

  builder = String::Builder.new

  start_index = 0

  while start_index < text.size
    match_length = 0
    while trie.contains_key_prefix?(text[start_index, match_length + 1])
      match_length += 1
    end
    if match_length > 0
      match = text[start_index, match_length]
      builder << "["
      builder << match
      builder << "|"
      builder << trie[match]
      builder << "]"
      start_index += match_length
    else
      builder << text[start_index]
      start_index += 1
    end
  end
  puts builder.to_s
  # [日本料理|japanese food]の中で、[一番|first and foremost][美味しい|tasty]のは[お寿司|sushi][だと思います|i think]。すぐ[日本|japan]に帰りたいです。
end


describe Crystalmoji do

  key_mapper = CrystalMoji::Trie::StringKeyMapper.new
  key = "abc"

  puts "0 => #{key_mapper.set?(0, key)}"
  puts "1 => #{key_mapper.set?(1, key)}"
  puts "2 => #{key_mapper.set?(2, key)}"
  puts "3 => #{key_mapper.set?(3, key)}"

  puts "4 => #{key_mapper.set?(4, key)}"
  puts "5 => #{key_mapper.set?(5, key)}"
  puts "6 => #{key_mapper.set?(6, key)}"
  puts "7 => #{key_mapper.set?(7, key)}"

  puts "8 => #{key_mapper.set?(8, key)}"
  puts "9 => #{key_mapper.set?(9, key)}"    # true
  puts "10 => #{key_mapper.set?(10, key)}"  # true
  puts "11 => #{key_mapper.set?(11, key)}"

  puts "12 => #{key_mapper.set?(12, key)}"
  puts "13 => #{key_mapper.set?(13, key)}"
  puts "14 => #{key_mapper.set?(14, key)}"
  puts "15 => #{key_mapper.set?(15, key)}"  # true

  puts "16 => #{key_mapper.set?(16, key)}"
  puts "17 => #{key_mapper.set?(17, key)}"
  puts "18 => #{key_mapper.set?(18, key)}"
  puts "19 => #{key_mapper.set?(19, key)}"

  puts "20 => #{key_mapper.set?(20, key)}"
  puts "21 => #{key_mapper.set?(21, key)}"
  puts "22 => #{key_mapper.set?(22, key)}"
  puts "23 => #{key_mapper.set?(23, key)}"

  puts "24 => #{key_mapper.set?(24, key)}"
  puts "25 => #{key_mapper.set?(25, key)}"  # true
  puts "26 => #{key_mapper.set?(26, key)}"  # true
  puts "27 => #{key_mapper.set?(27, key)}"

  puts "28 => #{key_mapper.set?(28, key)}"
  puts "29 => #{key_mapper.set?(29, key)}"
  puts "30 => #{key_mapper.set?(30, key)}"  # true
  puts "31 => #{key_mapper.set?(31, key)}"

  puts "32 => #{key_mapper.set?(32, key)}"
  puts "33 => #{key_mapper.set?(33, key)}"
  puts "34 => #{key_mapper.set?(34, key)}"
  puts "35 => #{key_mapper.set?(35, key)}"

  puts "36 => #{key_mapper.set?(36, key)}"
  puts "37 => #{key_mapper.set?(37, key)}"
  puts "38 => #{key_mapper.set?(38, key)}"
  puts "39 => #{key_mapper.set?(39, key)}"

  puts "40 => #{key_mapper.set?(40, key)}"
  puts "41 => #{key_mapper.set?(41, key)}"  # true
  puts "42 => #{key_mapper.set?(42, key)}"  # true
  puts "43 => #{key_mapper.set?(43, key)}"

  puts "44 => #{key_mapper.set?(44, key)}"
  puts "45 => #{key_mapper.set?(45, key)}"
  puts "46 => #{key_mapper.set?(46, key)}"  # true
  puts "47 => #{key_mapper.set?(47, key)}"  # true

end

describe Crystalmoji do

  key_mapper = CrystalMoji::Trie::StringKeyMapper.new

  puts "0 => #{key_mapper.set?(0, nil)}"
  puts "100 => #{key_mapper.set?(100, nil)}"
  puts "1000 => #{key_mapper.set?(1000, nil)}"
end

describe Crystalmoji do

  key_mapper = CrystalMoji::Trie::StringKeyMapper.new

  puts "0 => #{key_mapper.set?(0, "")}"       # true
  puts "100 => #{key_mapper.set?(100, "")}"   # true
  puts "1000 => #{key_mapper.set?(1000, "")}" # true

end

describe Crystalmoji do

  key_mapper = CrystalMoji::Trie::StringKeyMapper.new
  key = "a"

  puts "0 => #{key_mapper.set?(0, key)}"
  puts "1 => #{key_mapper.set?(1, key)}"
  puts "2 => #{key_mapper.set?(2, key)}"
  puts "3 => #{key_mapper.set?(3, key)}"

  puts "4 => #{key_mapper.set?(4, key)}"
  puts "5 => #{key_mapper.set?(5, key)}"
  puts "6 => #{key_mapper.set?(6, key)}"
  puts "7 => #{key_mapper.set?(7, key)}"

  puts "8 => #{key_mapper.set?(8, key)}"
  puts "9 => #{key_mapper.set?(9, key)}"    # true
  puts "10 => #{key_mapper.set?(10, key)}"  # true
  puts "11 => #{key_mapper.set?(11, key)}"

  puts "12 => #{key_mapper.set?(12, key)}"
  puts "13 => #{key_mapper.set?(13, key)}"
  puts "14 => #{key_mapper.set?(14, key)}"
  puts "15 => #{key_mapper.set?(15, key)}"  # true

  puts "16 => #{key_mapper.set?(16, key)}"  # true
  puts "17 => #{key_mapper.set?(17, key)}"  # true
  puts "100 => #{key_mapper.set?(100, key)}"  # true

end
