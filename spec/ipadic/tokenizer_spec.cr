require "../spec_helper"

def assert_token_surfaces_equals(expected_surfaces : Array(String), actual_tokens : Array(CrystalMoji::TokenBase))
  actual_surfaces = [] of String

  actual_tokens.each do |token|
    actual_surfaces << token.surface
  end

  puts "expected_surfaces: #{expected_surfaces}"
  puts "actual_surfaces: #{actual_surfaces}"
end


tokenizer = CrystalMoji::Ipadic::Tokenizer.new


describe Crystalmoji do
  input = "スペースステーションに行きます。うたがわしい。"
  surfaces = ["スペース", "ステーション", "に", "行き", "ます", "。", "うたがわしい", "。"]

  assert_token_surfaces_equals(surfaces, tokenizer.tokenize(input))
end

