require "./compiler"
require "../buffer/buffer_entry"
require "../iio/byte_buffer_io"

module CrystalMoji::Compile
  class TokenInfoBufferCompiler
    include Compiler

    @@integer_bytes = 4
    @@short_bytes = 2

    @buffer : IO
    @output : IO

    def initialize(@output, entries : Array(CrystalMoji::Buffer::BufferEntry))
      @buffer = IO::Memory.new
      put_entries(entries)
    end

    def put_entries(entries : Array(CrystalMoji::Buffer::BufferEntry))
      size = calculate_entries_size(entries) * 2

      # 写入头部信息
      @buffer.write_bytes(size, IO::ByteFormat::BigEndian)
      @buffer.write_bytes(entries.size, IO::ByteFormat::BigEndian)

      first_entry = entries.first
      @buffer.write_bytes(first_entry.token_info.size, IO::ByteFormat::BigEndian)
      @buffer.write_bytes(first_entry.pos_info.size, IO::ByteFormat::BigEndian)
      @buffer.write_bytes(first_entry.features.size, IO::ByteFormat::BigEndian)

      # 写入所有条目的数据
      entries.each do |entry|
        entry.token_info.each do |s|
          @buffer.write_bytes(s, IO::ByteFormat::BigEndian)
        end

        entry.pos_info.each do |b|
          @buffer.write_byte(b)
        end

        entry.features.each do |feature|
          @buffer.write_bytes(feature, IO::ByteFormat::BigEndian)
        end
      end
    end

    private def calculate_entries_size(entries : Array(CrystalMoji::Buffer::BufferEntry)) : Int32
      return 0 if entries.empty?

      size = 0
      entry = entries.first
      size += entry.token_info.size * @@short_bytes + @@short_bytes
      size += entry.pos_info.size
      size += entry.features.size * @@integer_bytes
      size *= entries.size
      size
    end

    def compile
      # 将内存缓冲区的内容写入输出流
      @buffer.rewind
      CrystalMoji::IIO::ByteBufferIO.write(@output, @buffer.getb_to_end)
      @output.close
    end

  end
end
