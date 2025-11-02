require "../util/utf_util"

module CrystalMoji::IIO
  class StringArrayIO
    def self.read_array(input : IO, encoding : String = "UTF-8") : Array(String)
      # 读取数组长度
      length = input.read_bytes(Int32, IO::ByteFormat::BigEndian)

      # 创建数组并读取每个字符串
      Array.new(length) do
        CrystalMoji::Util::UTFUtil.read_utf(input)
        # read_utf_string(input)
      end
    end

    def self.write_array(output : IO, array : Array(String))
      # 写入数组长度
      output.write_bytes(array.size, IO::ByteFormat::BigEndian)

      # 写入每个字符串
      array.each do |str|
        CrystalMoji::Util::UTFUtil.write_utf(output, str)
        # write_utf_string(output, str)
      end
    end

    def self.read_array_2d(input : IO, encoding : String = "UTF-8") : Array(Array(String))
      # 读取二维数组长度
      length = input.read_bytes(Int32, IO::ByteFormat::BigEndian)

      # 创建二维数组并读取每个一维数组
      Array.new(length) do
        read_array(input, encoding)
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
