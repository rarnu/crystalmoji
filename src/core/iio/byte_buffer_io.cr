module CrystalMoji::IIO
  class ByteBufferIO
    def self.read(input : IO) : Bytes
      # 读取大小 (4字节，大端序)
      size = read_int32_big_endian(input)

      # 分配字节缓冲区
      buffer = Bytes.new(size)

      # 读取数据到缓冲区
      bytes_read = 0
      while bytes_read < size
        read_count = input.read(buffer + bytes_read)
        break if read_count == 0 # EOF
        bytes_read += read_count
      end

      if bytes_read < size
        raise IO::Error.new("Failed to read complete buffer: expected #{size} bytes, got #{bytes_read}")
      end

      buffer
    end

    # 写入方法 - 与 Java write 方法完全一致
    def self.write(output : IO, buffer : Bytes)
      # 写入缓冲区容量 (4字节，大端序)
      write_int32_big_endian(output, buffer.size)

      # 写入缓冲区内容
      output.write(buffer)
      output.flush
    end

    # 辅助方法：读取大端序的 Int32
    private def self.read_int32_big_endian(io : IO) : Int32
      bytes = Bytes.new(4)
      io.read_fully(bytes)

      (bytes[0].to_i32 << 24) |
        (bytes[1].to_i32 << 16) |
        (bytes[2].to_i32 << 8) |
        bytes[3].to_i32
    end

    # 辅助方法：写入大端序的 Int32
    private def self.write_int32_big_endian(io : IO, value : Int32)
      bytes = Bytes.new(4)
      bytes[0] = ((value >> 24) & 0xFF).to_u8
      bytes[1] = ((value >> 16) & 0xFF).to_u8
      bytes[2] = ((value >> 8) & 0xFF).to_u8
      bytes[3] = (value & 0xFF).to_u8

      io.write(bytes)
    end
  end
end
