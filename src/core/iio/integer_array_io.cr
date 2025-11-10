module CrystalMoji::IIO
  class IntegerArrayIO
    # Crystal 中 Int32 的大小是 4 字节
    @@int_bytes = 4

    def self.read_arrays(input : IO, array_count : Int32) : Array(Array(Int32))
      Array.new(array_count) do
        read_array_from_io(input)
      end
    end

    def self.write_array(output : IO, array : Array(Int32)) : Nil
      # 写入数组长度
      output.write_bytes(array.size, IO::ByteFormat::BigEndian)

      # 直接写入整数数组
      array.each do |value|
        output.write_bytes(value, IO::ByteFormat::BigEndian)
      end
    end

    def self.read_array_2d(input : IO) : Array(Array(Int32))
      # 读取二维数组长度
      array_count = input.read_bytes(Int32, IO::ByteFormat::BigEndian)
      read_arrays(input, array_count)
    end

    def self.write_array_2d(output : IO, array : Array(Array(Int32))) : Nil
      # 写入二维数组长度
      output.write_bytes(array.size, IO::ByteFormat::BigEndian)

      # 写入每个一维数组
      array.each do |inner_array|
        write_array(output, inner_array)
      end
    end

    def self.read_sparse_array_2d(input : IO) : Array(Array(Int32)?)
      # 读取数组长度
      array_count = input.read_bytes(Int32, IO::ByteFormat::BigEndian)

      # 创建可空的二维数组
      array = Array(Array(Int32)?).new(array_count, nil)

      # 读取稀疏数据直到遇到结束标记
      while (index = read_int_from_io(input)) >= 0
        array[index] = read_array_from_io(input)
      end

      array
    end

    def self.write_sparse_array_2d(output : IO, array : Array(Array(Int32)?)) : Nil
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

    # 辅助方法：从 IO 读取一个整数
    private def self.read_int_from_io(input : IO) : Int32
      input.read_bytes(Int32, IO::ByteFormat::BigEndian)
    end

    # 辅助方法：从 IO 读取一个整数数组
    private def self.read_array_from_io(input : IO) : Array(Int32)
      # 读取数组长度
      length = read_int_from_io(input)

      # 读取指定数量的整数
      Array.new(length) do
        read_int_from_io(input)
      end
    end
  end
end
