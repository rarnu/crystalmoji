require "../spec_helper"

describe Crystalmoji do
  array = CrystalMoji::Compile::WordIdMapCompiler::GrowableIntArray.new(5)
  array.set(3, 1)
  puts array.get_array # [0, 0, 0, 1]
  array.set(0, 2)
  array.set(10, 3)
  puts array.get_array # [2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 3]
end


describe Crystalmoji do
  compiler = CrystalMoji::Compile::WordIdMapCompiler.new
  compiler.add_mapping(3, 1)
  compiler.add_mapping(3, 2)
  compiler.add_mapping(3, 3)
  compiler.add_mapping(10, 0)

  file = File.tempfile("kuromoji-wordid-.bin")
  output = File.open(file.path, "w")
  compiler.write(output)
  output.close

  input = File.open(file.path, "r")
  word_ids = CrystalMoji::Buffer::WordIdMap.new(input)
  puts word_ids.look_up(3) # [1, 2, 3]
  puts word_ids.look_up(10) # [0]
  puts word_ids.look_up(1) # []

end

