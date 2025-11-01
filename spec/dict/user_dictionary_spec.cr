require "../spec_helper"

describe Crystalmoji do
  f = File.open("./res/userdict.txt")
  dictionary = CrystalMoji::Dict::UserDictionary.new(f, 9, 7, 0)
  matches = dictionary.find_user_dictionary_matches("関西国際空港に行った")
  puts "size = #{matches.size}" # 3

  puts "関西 = #{matches[0].match_start_index}" # 0
  puts "国際 = #{matches[1].match_start_index}" # 2
  puts "空港 = #{matches[2].match_start_index}" # 4

  puts "関西 = #{matches[0].match_length}"  #2
  puts "国際 = #{matches[1].match_length}"  #2
  puts "空港 = #{matches[2].match_length}"  #2

  matches2 = dictionary.find_user_dictionary_matches("関西国際空港と関西国際空港に行った")
  puts "size = #{matches2.size}" # 6
end

describe Crystalmoji do
  f = File.open("./res/userdict.txt")
  dictionary = CrystalMoji::Dict::UserDictionary.new(f, 9, 7, 0)
  features = dictionary.get_all_features(0)
  puts features # "カスタム名詞,*,*,*,*,*,*,ニホン,*"
end


describe Crystalmoji do
  f = File.open("./res/userdict.txt")
  dictionary = CrystalMoji::Dict::UserDictionary.new(f, 7, 5, 0)
  features = dictionary.get_all_features(0)
  puts features # "カスタム名詞,*,*,*,*,ニホン,*"
end


describe Crystalmoji do
  f = File.open("./res/userdict.txt")
  dictionary = CrystalMoji::Dict::UserDictionary.new(f, 11, 7, 0)
  features = dictionary.get_all_features(0)
  puts features # "カスタム名詞,*,*,*,*,*,*,ニホン,*,*,*"
end


describe Crystalmoji do
  f = File.open("./res/userdict.txt")
  dictionary = CrystalMoji::Dict::UserDictionary.new(f, 13, 7, 0)
  features = dictionary.get_all_features(0)
  puts features # "カスタム名詞,*,*,*,*,*,*,ニホン,*,*,*,*,*"
end

describe Crystalmoji do
  f = File.open("./res/userdict.txt")
  dictionary = CrystalMoji::Dict::UserDictionary.new(f, 22, 13, 0)
  features = dictionary.get_all_features(0)
  puts features # "カスタム名詞,*,*,*,*,*,*,*,*,*,*,*,*,ニホン,*,*,*,*,*,*,*,*"
end

describe Crystalmoji do
  user_dictionary_entry = "クロ,クロ,クロ,カスタム名詞"
  bais = IO::Memory.new(user_dictionary_entry.to_slice)
  dictionary = CrystalMoji::Dict::UserDictionary.new(bais, 9, 7, 0)
  matches = dictionary.find_user_dictionary_matches("この丘はアクロポリスと呼ばれている")
  puts "size = #{matches.size}" # 1
  puts "5 => #{matches[0].match_start_index}"
end

describe Crystalmoji do
  user_dictionary_entries = "クロ,クロ,クロ,カスタム名詞\nアクロ,アクロ,アクロ,カスタム名詞"
  bais = IO::Memory.new(user_dictionary_entries.to_slice)
  dictionary = CrystalMoji::Dict::UserDictionary.new(bais, 9, 7, 0)
  matches = dictionary.find_user_dictionary_matches("この丘はアクロポリスと呼ばれている")

  puts "size = #{matches.size}" # 2
  puts "4 => #{matches[0].match_start_index}"
end

describe Crystalmoji do

end



