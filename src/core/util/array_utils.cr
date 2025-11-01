module ArrayExtension(T)
  def to_slice : Slice(T)
    Slice.new(@buffer, size)
  end

  def contains?(value : T) : Bool
    !index(value).nil?
  end

  def contains_all?(values : Array(T)) : Bool
    values.all? { |value| contains?(value) }
  end
end

class Array(T)
  include ArrayExtension(T)
end

module BytesExtension
  def to_short_buffer(byte_order : IO::ByteFormat = IO::ByteFormat::BigEndian) : Slice(Int16)
    # 检查字节数是否为偶数（因为每个 Int16 占 2 个字节）
    if self.size % 2 != 0
      raise ArgumentError.new("Byte buffer size must be even for short buffer conversion")
    end

      # 计算可以容纳的 Int16 数量
    short_count = self.size // 2
    result = Array(Int16).new(short_count)

    # 创建内存 IO 来读取字节
    io = IO::Memory.new(self)

    short_count.times do
      result << io.read_bytes(Int16, byte_order)
    end

    result.to_slice

  end
end

struct Slice(T)
  include BytesExtension
end
