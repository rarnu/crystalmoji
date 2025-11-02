require "../spec_helper"

def given(input : String) : String
  CrystalMoji::Util::DictionaryEntryLineParser.parse_line(input).join(",")
end

describe Crystalmoji do
  puts CrystalMoji::Util::DictionaryEntryLineParser.parse_line("日本経済新聞,日本 経済 新聞,ニホン ケイザイ シンブン,カスタム名詞")
  # ["日本経済新聞", "日本 経済 新聞", "ニホン ケイザイ シンブン", "カスタム名詞"]
end

describe Crystalmoji do
  puts CrystalMoji::Util::DictionaryEntryLineParser.parse_line("\"Java Platform, Standard Edition\",\"Java Platform, Standard Edition\",\"Java Platform, Standard Edition\",カスタム名詞")
  # ["Java Platform, Standard Edition", "Java Platform, Standard Edition", "Java Platform, Standard Edition", "カスタム名詞"]
end

describe Crystalmoji do
  puts CrystalMoji::Util::DictionaryEntryLineParser.parse_line("\"Java \"\"Platform\"\"\",\"Java \"\"Platform\"\"\",\"Java \"\"Platform\"\"\",カスタム名詞")
  # ["Java \"Platform\"", "Java \"Platform\"", "Java \"Platform\"", "カスタム名詞"]
end

describe Crystalmoji do
  puts CrystalMoji::Util::DictionaryEntryLineParser.parse_line("\"\"\"\",\"\"\"\",quote,punctuation")
  # ["\"", "\"", "quote", "punctuation"]
end

describe Crystalmoji do
  puts CrystalMoji::Util::DictionaryEntryLineParser.parse_line("\"C#\",\"C #\",シーシャープ,プログラミング言語")
  # ["C#", "C #", "シーシャープ", "プログラミング言語"]
end

describe Crystalmoji do
  puts CrystalMoji::Util::DictionaryEntryLineParser.parse_line("A\tB,A B,A B,tab")
  # ["A\tB", "A B", "A B", "tab"]
end

describe Crystalmoji do
  puts CrystalMoji::Util::DictionaryEntryLineParser.parse_line("\"フランソワ\"\"ザホワイトバッファロー\"\"ボタ\",\"フランソワ\"\"ザホワイトバッファロー\"\"ボタ\",\"フランソワ\"\"ザホワイトバッファロー\"\"ボタ\",名詞")
  # ["フランソワ\"ザホワイトバッファロー\"ボタ", "フランソワ\"ザホワイトバッファロー\"ボタ", "フランソワ\"ザホワイトバッファロー\"ボタ", "名詞"]
end

describe Crystalmoji do
  begin
    puts CrystalMoji::Util::DictionaryEntryLineParser.parse_line("this is an entry with \"unmatched quote")
  rescue e
    puts e # unmatched quote
  end
end

describe Crystalmoji do
  begin
    puts CrystalMoji::Util::DictionaryEntryLineParser.parse_line("this is an entry with \"\"\"unmatched quote")
  rescue e
    puts e # unmatched quote
  end
end

describe Crystalmoji do
  original = "3,\"14"

  puts CrystalMoji::Util::DictionaryEntryLineParser.escape(original) # "\"3,\"\"14\""

  puts CrystalMoji::Util::DictionaryEntryLineParser.unescape(CrystalMoji::Util::DictionaryEntryLineParser.escape(original))

end

describe Crystalmoji do
  puts CrystalMoji::Util::DictionaryEntryLineParser.unescape("\"A\"")  # A
  puts CrystalMoji::Util::DictionaryEntryLineParser.unescape("\"\"\"A\"\"\"")  # "A"
  puts CrystalMoji::Util::DictionaryEntryLineParser.unescape("\"\"\"\"")  # "
  puts CrystalMoji::Util::DictionaryEntryLineParser.unescape("\"\"\"\"\"\"")  # ""
  puts CrystalMoji::Util::DictionaryEntryLineParser.unescape("\"\"\"\"\"\"\"\"")  # """
  puts CrystalMoji::Util::DictionaryEntryLineParser.unescape("\"\"\"\"\"\"\"\"\"\"\"\"")  # """"
end

describe Crystalmoji do
  input = "日本経済新聞,1292,1292,4980,名詞,固有名詞,組織,*,*,*,日本経済新聞,ニホンケイザイシンブン,ニホンケイザイシンブン"
  expected = ["日本経済新聞", "1292", "1292", "4980", "名詞", "固有名詞", "組織", "*", "*", "*", "日本経済新聞", "ニホンケイザイシンブン", "ニホンケイザイシンブン"].join(",")
  expected.should eq(given(input))
end

describe Crystalmoji do
  input = "日本経済新聞,1292,1292,4980,名詞,固有名詞,組織,*,*,\"1,0\",日本経済新聞,ニホンケイザイシンブン,ニホンケイザイシンブン"
  expected = ["日本経済新聞", "1292", "1292", "4980","名詞", "固有名詞", "組織", "*", "*", "1,0", "日本経済新聞", "ニホンケイザイシンブン", "ニホンケイザイシンブン"].join(",")
  expected.should eq(given(input))
end

describe Crystalmoji do
  input = "日本経済新聞,1292,1292,4980,名詞,固有名詞,組織,*,*,\"1,0\",日本経済新聞,ニホンケイザイシンブン,ニホンケイザイシンブン"
  expected = "\"日本経済新聞,1292,1292,4980,名詞,固有名詞,組織,*,*,\"\"1,0\"\",日本経済新聞,ニホンケイザイシンブン,ニホンケイザイシンブン\""
  expected.should eq(CrystalMoji::Util::DictionaryEntryLineParser.escape(input))
end
