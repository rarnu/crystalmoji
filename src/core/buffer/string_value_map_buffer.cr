require "../iio/byte_buffer_io"

module CrystalMoji::Buffer
  class StringValueMapBuffer
    # 常量定义
    @@INTEGER_BYTES = 4
    @@SHORT_BYTES = 2
    @@KATAKANA_FLAG = 0x8000_u16
    @@KATAKANA_LENGTH_MASK = 0x7fff_u16
    @@KATAKANA_BASE = '\u3000' # 片假名起始于 U+3000

    @buffer : Bytes = Bytes.empty
    @size : Int32 = 0

    def initialize(features : Hash(Int32, String))
      put(features)
    end

    def initialize(input : IO)
      @buffer = CrystalMoji::IIO::ByteBufferIO.read(input)
      @size = read_int(0)
    end

    # 根据键获取值
    def get(key : Int32) : String
      raise "Key out of range: #{key}" unless key >= 0 && key < @size

      key_index = (key + 1) * @@INTEGER_BYTES
      value_index = read_int(key_index)
      length = read_short(value_index).to_i32

      if (length & @@KATAKANA_FLAG) != 0
        length &= @@KATAKANA_LENGTH_MASK
        get_katakana_string(value_index + @@SHORT_BYTES, length)
      else
        get_string(value_index + @@SHORT_BYTES, length)
      end
    end

    # 写入到输出流
    def write(output : IO) : Nil
      ByteBufferIO.write(output, @buffer)
    end

    private def get_katakana_string(value_index : Int32, length : Int32) : String
      String.build(length) do |str|
        length.times do |i|
          char_code = @@KATAKANA_BASE.ord + @buffer[value_index + i]
          str << char_code.chr
        end
      end
    end

    private def get_string(value_index : Int32, length : Int32) : String
      # UTF-16LE 编码读取（Crystal 默认使用 UTF-8，这里需要特殊处理）
      slice = @buffer[value_index, length]
      # decode_utf16le(slice)
      String.new(slice, "UTF-16")
    end

    private def put(strings : Hash(Int32, String)) : Nil
      buffer_size = calculate_size(strings)
      @size = strings.size

      # 创建缓冲区
      @buffer = Bytes.new(buffer_size)

      # 写入条目数量
      write_int(0, @size)

      key_index = @@INTEGER_BYTES # 第一个键索引在大小之后
      entry_index = key_index + @size * @@INTEGER_BYTES

      # 按键排序后处理
      strings.keys.sort.each do |key|
        value = strings[key]
        write_int(key_index, entry_index)
        entry_index = put_string(entry_index, value)
        key_index += @@INTEGER_BYTES
      end
    end

    private def calculate_size(strings : Hash(Int32, String)) : Int32
      size = @@INTEGER_BYTES + strings.size * @@INTEGER_BYTES

      strings.each_value do |value|
        size += @@SHORT_BYTES + get_byte_size(value)
      end
      size
    end

    private def get_byte_size(string : String) : Int32
      if katakana?(string)
        string.size
      else
        get_utf16_bytes(string).size
      end
    end

    private def put_string(index : Int32, value : String) : Int32
      is_katakana = katakana?(value)
      bytes : Bytes
      length : UInt16

      if is_katakana
        bytes = get_katakana_bytes(value)
        length = (bytes.size | @@KATAKANA_FLAG).to_u16
      else
        bytes = get_utf16_bytes(value)
        length = bytes.size.to_u16
      end

      raise "String too long: #{bytes.size} (max: #{Int16::MAX})" if bytes.size >= Int16::MAX

      # 写入长度和字节数据
      write_short(index, length)
      bytes.each_with_index do |byte, i|
        @buffer[index + @@SHORT_BYTES + i] = byte
      end

      index + @@SHORT_BYTES + bytes.size
    end

    private def get_katakana_bytes(string : String) : Bytes
      bytes = Bytes.new(string.size)
      string.each_char_with_index do |char, i|
        bytes[i] = (char.ord - @@KATAKANA_BASE.ord).to_u8
      end
      bytes
    end

    private def get_utf16_bytes(string : String) : Bytes
      # 将 UTF-8 字符串转换为 UTF-16LE 字节
      string.encode("UTF-16").to_slice
    end

    # 判断字符串是否全部为片假名
    private def katakana?(string : String) : Bool
      string.each_char do |char|
        # 片假名 Unicode 范围：U+30A0 到 U+30FF
        return false unless (0x30A0 <= char.ord <= 0x30FF)
      end
      true
    end

    # 辅助方法：从缓冲区读取整数（大端序）
    private def read_int(position : Int32) : Int32
      slice = @buffer[position, @@INTEGER_BYTES]
      (slice[0].to_i32 & 0xff) << 24 |
        (slice[1].to_i32 & 0xff) << 16 |
        (slice[2].to_i32 & 0xff) << 8 |
        (slice[3].to_i32 & 0xff)
    end

    # 辅助方法：从缓冲区读取短整数（大端序）
    private def read_short(position : Int32) : UInt16
      slice = @buffer[position, @@SHORT_BYTES]
      ((slice[0].to_i32 & 0xff) << 8 | (slice[1].to_i32 & 0xff)).to_u16
    end

    # 辅助方法：向缓冲区写入整数（大端序）
    private def write_int(position : Int32, value : Int32) : Nil
      @buffer[position] = ((value >> 24) & 0xff).to_u8
      @buffer[position + 1] = ((value >> 16) & 0xff).to_u8
      @buffer[position + 2] = ((value >> 8) & 0xff).to_u8
      @buffer[position + 3] = (value & 0xff).to_u8
    end

    # 辅助方法：向缓冲区写入短整数（大端序）
    private def write_short(position : Int32, value : UInt16) : Nil
      @buffer[position] = ((value >> 8) & 0xff).to_u8
      @buffer[position + 1] = (value & 0xff).to_u8
    end
  end
end
