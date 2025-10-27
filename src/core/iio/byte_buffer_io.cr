module CrystalMoji::IIO
  class ByteBufferIO
    def self.read(input : IO) : Bytes
      # 读取大小（4字节整数）
      size = input.read_bytes(Int32, IO::ByteFormat::BigEndian)

      # 分配字节缓冲区
      buffer = Bytes.new(size)

      # 读取数据到缓冲区
      bytes_read = 0
      while bytes_read < size
        bytes_read += input.read(buffer + bytes_read, size - bytes_read)
      end

      buffer
    end

    def self.write(output : IO, buffer : Bytes) : Nil
      # 写入缓冲区大小
      output.write_bytes(buffer.size, IO::ByteFormat::BigEndian)

      # 写入缓冲区内容
      output.write(buffer)
      output.flush
    end
  end
end
