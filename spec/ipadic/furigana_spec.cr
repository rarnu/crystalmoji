require "../spec_helper"

describe Crystalmoji do
  input = "高い攻撃力を誇る伝説のドラゴン。どんな相手でも粉砕する、その破壊力は計り知れない。"
  tokenizer = CrystalMoji::Ipadic::Tokenizer.new
  tokens = tokenizer.tokenize(input)
  tokens.each do |token|
    puts token.furigana
  end
end

describe Crystalmoji do
  input = "高い攻撃力を誇る伝説のドラゴン。どんな相手でも粉砕する、その破壊力は計り知れない。"
  tokenizer = CrystalMoji::Ipadic::Tokenizer.new
  s1 = tokenizer.furigana(input)
  s2 = tokenizer.remove_furigana(s1)
  puts s1
  puts s2
end
