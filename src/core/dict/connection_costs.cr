require "../util/resource_resolver"
require "../iio/byte_buffer_io"

module CrystalMoji::Dict

  class ConnectionCosts

    class_property connection_costs_filename = "connectionCosts.bin"

    @size : Int32
    @costs : Slice(Int16)

    def initialize(@size, @costs)
    end

    def get(forward_id : Int32, backward_id : Int32) : Int32
      index = backward_id + forward_id * @size
      @costs[index].to_i32
    end

    def self.new_instance(resolver : CrystalMoji::Util::ResourceResolver) : ConnectionCosts
      io = resolver.resolve(connection_costs_filename)
      read(io)
    ensure
      io.try(&.close)
    end

    private def self.read(input : IO) : ConnectionCosts
      # 读取 size
      size = read_int32(input)

      byte_buffer = CrystalMoji::IIO::ByteBufferIO.read(input)
      costs

      ConnectionCosts.new(size, costs)
    end

    private def self.read_int32(io : IO) : Int32
      bytes = io.read_bytes(4)
      # 假设是大端序，根据实际文件格式调整
      bytes[0].to_i32 << 24 | bytes[1].to_i32 << 16 | bytes[2].to_i32 << 8 | bytes[3].to_i32
    end

  end

end
