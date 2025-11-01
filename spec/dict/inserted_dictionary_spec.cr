require "../spec_helper"

describe Crystalmoji do

  dictionary1 = CrystalMoji::Dict::InsertedDictionary.new(9)
  dictionary2 = CrystalMoji::Dict::InsertedDictionary.new(5)

  f1 = dictionary1.get_all_features(0)
  puts "f1 => #{f1 == "*,*,*,*,*,*,*,*,*"}"
  f2 = dictionary2.get_all_features(0)
  puts "f2 => #{f2 == "*,*,*,*,*"}"

  a1 = dictionary1.get_all_features_array(0)
  puts "a1 => #{a1 == ["*", "*", "*", "*", "*", "*", "*", "*", "*"]}"
  a2 = dictionary2.get_all_features_array(0)
  puts "a2 => #{a2 == ["*", "*", "*", "*", "*"]}"

end

