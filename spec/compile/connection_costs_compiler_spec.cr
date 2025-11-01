require "../spec_helper"

describe Crystalmoji do

  costs_file = File.tempfile("kuromoji-connectioncosts-.bin")
  costs = "3 3\n0 0 1\n0 1 2\n0 2 3\n1 0 4\n1 1 5\n1 2 6\n2 0 7\n2 1 8\n2 2 9\n"

  compiler = CrystalMoji::Compile::ConnectionCostsCompiler.new(File.open(costs_file.path, "w"))
  compiler.read_costs(IO::Memory.new(costs))
  compiler.compile

  data_input = File.open(costs_file.path, "r")
  size = data_input.read_bytes(Int32, IO::ByteFormat::BigEndian)

  costs_buffer = CrystalMoji::IIO::ByteBufferIO.read(data_input).to_short_buffer
  data_input.close

  connection_costs = CrystalMoji::Dict::ConnectionCosts.new(size, costs_buffer)
  # case

  cost = 1

  for i = 0, i < 3, i+= 1 do
    for j = 0, j < 3, j+= 1 do
      cost.should eq(connection_costs.get(i, j))
      cost += 1
    end
  end

end
