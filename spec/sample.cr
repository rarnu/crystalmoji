require "./spec_helper"

describe Crystalmoji do
  num = 64729
  result = (num & Int16::MAX)
  puts (result - Int16::MAX - 1).to_i16  # => -807


  num = 32768
  result = (num & Int16::MAX)
  puts (result - Int16::MAX - 1).to_i16  # => -807


  puts 1 & Int16::MAX
  puts 64729 & Int16::MAX

  puts 31961 - Int16::MAX

  puts 32769 & Int16::MAX
end
