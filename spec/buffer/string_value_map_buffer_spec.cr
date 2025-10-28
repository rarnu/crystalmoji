require "../spec_helper"

describe Crystalmoji do
  input = {1 => "hello", 2 => "日本", 3 => "カタカナ", 0 => "Bye"}
  values = CrystalMoji::Buffer::StringValueMapBuffer.new(input)

  puts "Bye => #{values.get(0)}"
  puts "hello => #{values.get(1)}"
  puts "日本 => #{values.get(2)}"
  puts "カタカナ => #{values.get(3)}"
end
