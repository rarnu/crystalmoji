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
      io = resolver.resolve(ConnectionCosts.connection_costs_filename)
      read(io)
    ensure
      io.try(&.close)
    end

    private def self.read(input : IO) : ConnectionCosts
      size = read_int32(input)
      byte_buffer = CrystalMoji::IIO::ByteBufferIO.read(input)
      short_buffer = as_short_buffer(byte_buffer)
      ConnectionCosts.new(size, short_buffer)
    end

    private def self.read_int32(io : IO) : Int32
      bytes = Bytes.new(4)
      io.read(bytes)
      bytes[0].to_i32 << 24 | bytes[1].to_i32 << 16 | bytes[2].to_i32 << 8 | bytes[3].to_i32
    end



    private def self.as_short_buffer(bytes : Bytes, byte_order : Symbol = :big) : Slice(Int16)
      if bytes.size % 2 != 0
        raise "Byte array size must be even"
      end

      result = [] of Int16

      bytes.each_slice(2) do |byte_pair|
        if byte_order == :big
          result << ((byte_pair[0].to_i16 << 8) | byte_pair[1].to_i16)
        else
          result << ((byte_pair[1].to_i16 << 8) | byte_pair[0].to_i16)
        end
      end

      result.to_slice
    end

  end

end
