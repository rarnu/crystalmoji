require "./bits"

module CrystalMoji::FST
  class FST
    class_property fst_filename = "fst.bin"

    @fst : Bytes
    @jump_cache = Array(Int32).new(65536, -1)
    @output_cache = Array(Int32).new(65536, -1)

    def initialize(compiled : Bytes)
      @fst = compiled
      init_cache
    end

    private def init_cache
      address = @fst.size - 1

      state_type = Bits.get_byte(@fst, address)
      address -= 1

      jump_bytes = (state_type & 0x03) + 1
      output_bytes = ((state_type & 0x0c3 << 3) >> 3)

      arcs = Bits.get_short(@fst, address)
      address -= 2

      arcs.times do |i|
        output = Bits.get_int(@fst, address, output_bytes)
        address -= output_bytes

        jump = Bits.get_int(@fst, address, jump_bytes)
        address -= jump_bytes

        label = Bits.get_short(@fst, address)
        address -= 2

        @jump_cache[label] = jump
        @output_cache[label] = output
      end
    end

    def lookup(input : String) : Int32
      length = input.size
      address = @fst.size - 1
      accumulator = 0
      index = 0

      while true
        state_type_byte = Bits.get_byte(@fst, address)
        jump_bytes = (state_type_byte & 0x03) + 1
        output_bytes = ((state_type_byte & 0x03 << 3) >> 3)
        arc_size = 2 + jump_bytes + output_bytes
        state_type = state_type_byte & 0x80
        address -= 1

        if index == length
          accumulator = 0 if state_type == CrystalMoji::FST::Compiler.state_type_match
          return accumulator
        end

        matched = false
        c = input[index]
        if index == 0
          # 处理缓存的根弧
          jump = @jump_cache[c.ord]
          return -1 if jump == -1

          output = @output_cache[c.ord]
          accumulator += output

          address = jump
          matched = true
        else
          # 通过二分搜索输出弧来转换到下一个状态
          number_of_arcs = Bits.get_short(@fst, address)
          address -= 2

          return -1 if number_of_arcs == 0

          high = number_of_arcs - 1
          low = 0

          while low <= high
            middle = low + (high - low) // 2
            arc_addr = address - middle * arc_size

            label = get_arc_label(arc_addr, output_bytes, jump_bytes)

            if label == c.ord
              matched = true
              address = get_arc_jump(arc_addr, output_bytes, jump_bytes)
              accumulator += get_arc_output(arc_addr, output_bytes, jump_bytes)
              break
            elsif label > c.ord
              low = middle + 1
            else
              high = middle - 1
            end
          end
        end

        return -1 unless matched
        index += 1
      end
    end

    private def get_arc_label(arc_address : Int32, accumulate_bytes : Int32, jump_bytes : Int32) : Int32
      Bits.get_short(@fst, arc_address - (accumulate_bytes + jump_bytes))
    end

    private def get_arc_jump(arc_address : Int32, accumulate_bytes : Int32, jump_bytes : Int32) : Int32
      Bits.get_int(@fst, arc_address - accumulate_bytes, jump_bytes)
    end

    private def get_arc_output(arc_address : Int32, accumulate_bytes : Int32, jump_bytes : Int32) : Int32
      Bits.get_int(@fst, arc_address, accumulate_bytes)
    end
  end
end
