require "../iio/byte_buffer_io"
require "./buffer_entry"

module CrystalMoji::Buffer
  class TokenInfoBuffer
    @@INTEGER_BYTES = 4
    @@SHORT_BYTES = 2

    @buffer : Bytes
    @token_info_count : Int32
    @pos_info_count : Int32
    @feature_count : Int32
    @entry_size : Int32

    def initialize(input : IO)
      # 使用 ByteBufferIO 读取缓冲区数据
      @buffer = CrystalMoji::IIO::ByteBufferIO.read(input)

      # 读取各种计数信息
      @token_info_count = get_token_info_count
      @pos_info_count = get_pos_info_count
      @feature_count = get_feature_count
      @entry_size = get_entry_size(@token_info_count, @pos_info_count, @feature_count)
    end

    # 查找并返回指定偏移量的完整词条信息
    def lookup_entry(offset : Int32) : BufferEntry
      entry = BufferEntry.new(Array(Int16).new(@token_info_count, 0), Array(Int32).new(@feature_count, 0), Array(Int32).new(@pos_info_count, 0))

      position = get_position(offset, @entry_size)

      # 获取左侧ID、右侧ID和单词成本
      @token_info_count.times do |i|
        entry.token_infos[i] = read_short(position + i * SHORT_BYTES)
      end

      # 获取词性标签值（还不是字符串）
      @pos_info_count.times do |i|
        # 使用 0xff 进行无符号字节到整数的转换
        entry.pos_infos[i] = @buffer[position + @token_info_count * SHORT_BYTES + i].to_i32 & 0xff
      end

      # 获取字段值引用（字符串引用）
      @feature_count.times do |i|
        entry.feature_infos[i] = read_int(position + @token_info_count * SHORT_BYTES + @pos_info_count + i * INTEGER_BYTES)
      end

      entry
    end

    # 查找特定词条信息
    def lookup_token_info(offset : Int32, i : Int32) : Int32
      position = get_position(offset, @entry_size)
      read_short(position + i * SHORT_BYTES).to_i32
    end

    # 查找词性特征
    def lookup_part_of_speech_feature(offset : Int32, i : Int32) : Int32
      position = get_position(offset, @entry_size)
      @buffer[position + @token_info_count * SHORT_BYTES + i].to_i32 & 0xff
    end

    # 查找特征
    def lookup_feature(offset : Int32, i : Int32) : Int32
      position = get_position(offset, @entry_size)
      read_int(position + @token_info_count * SHORT_BYTES + @pos_info_count + (i - @pos_info_count) * INTEGER_BYTES)
    end

    # 检查是否为词性特征
    def part_of_speech_feature?(i : Int32) : Bool
      pos_info_count_ = get_pos_info_count
      i < pos_info_count_
    end

    private def get_token_info_count : Int32
      read_int(INTEGER_BYTES * 2)
    end

    private def get_pos_info_count : Int32
      ead_int(INTEGER_BYTES * 3)
    end

    private def get_feature_count : Int32
      read_int(INTEGER_BYTES * 4)
    end

    private def get_entry_size(token_info_count : Int32, pos_info_count : Int32, feature_count : Int32) : Int32
      token_info_count * SHORT_BYTES + pos_info_count + feature_count * INTEGER_BYTES
    end

    private def get_position(offset : Int32, entry_size : Int32) : Int32
      offset * entry_size + INTEGER_BYTES * 5
    end

    # 从缓冲区读取整数（大端序）
    private def read_int(position : Int32) : Int32
      slice = @buffer[position, INTEGER_BYTES]
      # 大端序转换
      (slice[0].to_i32 & 0xff) << 24 |
        (slice[1].to_i32 & 0xff) << 16 |
        (slice[2].to_i32 & 0xff) << 8 |
        (slice[3].to_i32 & 0xff)
    end

    # 从缓冲区读取短整数（大端序）
    private def read_short(position : Int32) : Int16
      slice = @buffer[position, SHORT_BYTES]
      # 大端序转换
      value = ((slice[0].to_i32 & 0xff) << 8) | (slice[1].to_i32 & 0xff)
      value.to_i16
    end
  end
end
