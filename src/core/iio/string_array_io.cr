module CrystalMoji::IIO
  class StringArrayIO
    def self.read_array(input : IO) : Array(String)
      # 读取数组长度
      length = input.read_bytes(Int32, IO::ByteFormat::BigEndian)

      # 创建数组并读取每个字符串
      Array.new(length) do
        read_utf_string(input)
      end
    end

    def self.write_array(output : IO, array : Array(String))
      # 写入数组长度
      output.write_bytes(array.size, IO::ByteFormat::BigEndian)

      # 写入每个字符串
      array.each do |str|
        write_utf_string(output, str)
      end
    end

    private def self.read_utf_string(input : IO) : String
      # 读取字符串长度（Java 的 UTF 格式使用无符号短整型表示长度）
      length = input.read_bytes(UInt16, IO::ByteFormat::BigEndian).to_i
      bytes = Bytes.new(length)

      # 读取字符串数据
      bytes_read = 0
      while bytes_read < length
        bytes_read += input.read(bytes + bytes_read, length - bytes_read)
      end

      # 将字节转换为字符串（UTF-8 编码）
      String.new(bytes)
    end

    private def self.write_utf_string(output : IO, str : String) : Nil
      # 将字符串转换为 UTF-8 字节
      bytes = str.to_slice

      # 检查长度是否超过限制（Java UTF 使用 2 字节长度）
      if bytes.size > UInt16::MAX
        raise "String too long: #{bytes.size} bytes (max: #{UInt16::MAX})"
      end

      # 写入长度和字节数据
      output.write_bytes(bytes.size.to_u16, IO::ByteFormat::BigEndian)
      output.write(bytes)
    end

    def self.read_array_2d(input : IO) : Array(Array(String))
      # 读取二维数组长度
      length = input.read_bytes(Int32, IO::ByteFormat::BigEndian)

      # 创建二维数组并读取每个一维数组
      Array.new(length) do
        read_array(input)
      end
    end

    def self.write_array_2d(output : IO, array : Array(Array(String))) : Nil
      # 写入二维数组长度
      output.write_bytes(array.size, IO::ByteFormat::BigEndian)

      # 写入每个一维数组
      array.each do |inner_array|
        write_array(output, inner_array)
      end
    end

    def self.read_sparse_array_2d(input : IO) : Array(Array(String)?)
      # 读取数组长度
      length = input.read_bytes(Int32, IO::ByteFormat::BigEndian)

      # 创建可空的二维数组
      array = Array(Array(String)?).new(length, nil)

      # 读取稀疏数据直到遇到结束标记
      while (index = input.read_bytes(Int32, IO::ByteFormat::BigEndian)) >= 0
        array[index] = read_array(input)
      end

      array
    end

    def self.write_sparse_array_2d(output : IO, array : Array(Array(String)?)) : Nil
      # 写入数组长度
      output.write_bytes(array.size, IO::ByteFormat::BigEndian)

      # 只写入非空的子数组
      array.each_with_index do |inner_array, i|
        if inner_array
          output.write_bytes(i, IO::ByteFormat::BigEndian)
          write_array(output, inner_array)
        end
      end

      # 写入结束标记
      output.write_bytes(-1, IO::ByteFormat::BigEndian)
    end
  end
end
