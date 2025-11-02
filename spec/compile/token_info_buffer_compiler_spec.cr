require "../spec_helper"

describe Crystalmoji do
  shorts = [] of Int16
  (0...10).each do |i|
    shorts << i.to_i16
  end
  buffer = Bytes.new(shorts.size * 2 + 2)
  io = IO::Memory.new(buffer)
  io.write_bytes(shorts.size.to_i16, IO::ByteFormat::LittleEndian)

  shorts.each do |s|
    io.write_bytes(s, IO::ByteFormat::LittleEndian)
  end

  io.rewind
  count = io.read_bytes(Int16, IO::ByteFormat::LittleEndian)

  read_shorts = [] of Int16
  count.times do
    read_shorts << io.read_bytes(Int16, IO::ByteFormat::LittleEndian)
  end

  shorts.each_with_index do |expected, i|
    read_shorts[i].should eq(expected)
  end
end

describe Crystalmoji do
  token_info = [1_i16, 2_i16, 3_i16]
  features = [73, 99]

  token_infos = [1_i16, 2_i16, 3_i16]
  feature_infos = [73, 99]

  entry = CrystalMoji::Buffer::BufferEntry.new(token_infos, feature_infos)
  entry.token_info = token_info
  entry.features = features

  buffer_entries = [entry]
  file = File.tempfile("kuromoji-tokeinfo-buffer-.bin", "w")
  compiler = CrystalMoji::Compile::TokenInfoBufferCompiler.new(File.open(file.path, "w"), buffer_entries)
  compiler.compile

  token_info_buffer2 = CrystalMoji::Buffer::TokenInfoBuffer.new(File.open(file.path, "r"))

  token_info_buffer2.lookup_feature(0, 1).should eq(99)
  token_info_buffer2.lookup_feature(0, 0).should eq(73)
end

describe Crystalmoji do
  result_map = {
    73 => "hello",
    42 => "今日は",
    99 => "素敵な世界",
  }
  token_info = [1_i16, 2_i16, 3_i16]
  features = [73, 99]

  entry = CrystalMoji::Buffer::BufferEntry.new
  entry.token_info = token_info
  entry.features = features
  buffer_entries = [entry]

  file = File.tempfile("kuromoji-tokeinfo-buffer-.bin")
  compiler = CrystalMoji::Compile::TokenInfoBufferCompiler.new(File.open(file.path, "w"), buffer_entries)
  compiler.compile

  token_info_buffer = CrystalMoji::Buffer::TokenInfoBuffer.new(File.open(file.path, "r"))
  result = token_info_buffer.lookup_entry(0)
  result_map[result.feature_infos.not_nil![0]].should eq("hello")
  result_map[result.feature_infos.not_nil![1]].should eq("素敵な世界")

end
