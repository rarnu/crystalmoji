require "../iio/integer_array_io"

module CrystalMoji::Buffer
  class WordIdMap
    @indices : Array(Int32)
    @word_ids : Array(Int32)

    # 使用空数组常量
    @empty = [] of Int32

    def initialize(input : IO)
      arrays = CrystalMoji::IIO::IntegerArrayIO.read_arrays(input, 2)
      @indices = arrays[0]
      @word_ids = arrays[1]
    end

    def look_up(source_id : Int32) : Array(Int32)
      index = @indices[source_id]

      # 如果索引为 -1，返回空数组
      return @empty.dup if index == -1

      # 从 word_ids 中提取指定范围的元素
      length = @word_ids[index]
      start_pos = index + 1
      end_pos = start_pos + length

      @word_ids[start_pos...end_pos]
    end
  end
end
