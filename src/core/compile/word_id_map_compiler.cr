require "./compiler"
require "../iio/integer_array_io"

module CrystalMoji::Compile
  class WordIdMapCompiler
    include Compiler

    @word_ids = [] of Array(Int32)?
    @indices : Array(Int32)?
    @word_id_array = GrowableIntArray.new

    def add_mapping(source_id : Int32, word_id : Int32)
      # 确保数组足够大
      if source_id >= @word_ids.size
        new_size = source_id + 1
        new_array = Array(Array(Int32)?).new(new_size, nil)
        @word_ids.each_with_index do |arr, i|
          new_array[i] = arr
        end
        @word_ids = new_array
      end

      # 获取或创建当前source_id的数组
      current = @word_ids[source_id]
      if current.nil?
        current = [word_id]
      else
        current = current + [word_id]
      end
      @word_ids[source_id] = current
    end

    def write(output : IO)
      compile
      # 假设IntegerArrayIO有对应的Crystal实现
      CrystalMoji::IIO::IntegerArrayIO.write_array(output, @indices.as(Array(Int32)))
      CrystalMoji::IIO::IntegerArrayIO.write_array(output, @word_id_array.get_array)
    end

    def compile
      @indices = Array(Int32).new(@word_ids.size, -1)
      word_id_index = 0

      @word_ids.each_with_index do |inner, i|
        if inner.nil?
          @indices.not_nil![i] = -1
        else
          @indices.not_nil![i] = word_id_index
          @word_id_array.set(word_id_index, inner.size)
          word_id_index += 1

          inner.each do |word_id|
            @word_id_array.set(word_id_index, word_id)
            word_id_index += 1
          end
        end
      end
    end

    class GrowableIntArray
      @@array_growth_rate : Float32 = 1.25
      @@array_initial_size : Int32 = 1024

      @array : Array(Int32)
      @max_index : Int32

      def initialize(size : Int32 = @@array_initial_size)
        @array = Array(Int32).new(size, 0)
        @max_index = -1
      end

      def get_array : Array(Int32)
        length = @max_index + 1
        @array[0, length]
      end

      def set(index : Int32, value : Int32)
        if index >= @array.size
          grow(get_new_length(index))
        end

        if index > @max_index
          @max_index = index
        end

        @array[index] = value
      end

      private def grow(new_length : Int32)
        new_array = Array(Int32).new(new_length, 0)
        @array.each_with_index do |val, i|
          new_array[i] = val
        end
        @array = new_array
      end

      private def get_new_length(index : Int32) : Int32
        new_size = (index + 1).to_f32
        growth_size = @array.size * @@array_growth_rate
        Math.max(new_size, growth_size).to_i
      end
    end
  end
end
