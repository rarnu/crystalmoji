require "./compiler"
require "./bits"

module CrystalMoji::FST
  class BitsFormatter
    @byte_output = IO::Memory.new

    def format(input : IO) : String
      buffered_input = IO::Buffered.new(input)

      while (next_byte = buffered_input.read_byte)
        @byte_output.write_byte(next_byte)
      end

      format(@byte_output.to_slice)
    end

    def format(fst : Bytes) : String
      builder = String::Builder.new
      address = fst.size - 1

      while address > 0
        st = format_state(fst, address)
        builder << st
        ss = state_size(fst, address)
        address -= ss
      end

      builder.to_s
    end

    def state_size(fst : Bytes, address : Int32) : Int32
      state_type_byte = Bits.get_byte(fst, address)
      jump_bytes = (state_type_byte & 0x03) + 1
      accumulate_bytes = (state_type_byte & 0x03 << 2) >> 3 # 修正位运算

      1 + 2 + Bits.get_short(fst, address - 1) * (2 + accumulate_bytes + jump_bytes)
    end

    def format_state(fst : Bytes, address : Int32) : String
      builder = String::Builder.new

      state_byte = Bits.get_byte(fst, address)
      state_type = state_byte & 0x80
      jump_bytes = (state_byte & 0x03) + 1
      accumulate_bytes = (state_byte & 0x03 << 3) >> 3 # 修正位运算

      fst1 = format_state_type(state_type, address)
      builder << fst1
      fst2 = format_arcs(fst, address - 1, accumulate_bytes, jump_bytes)
      builder << fst2

      builder.to_s
    end

    def format_state_type(state_byte : UInt8, address : Int32) : String
      builder = String::Builder.new
      builder << format_address(address)
      builder << " "

      if state_byte == Compiler.state_type_accept
        builder << "ACCEPT"
      elsif state_byte == Compiler.state_type_match
        builder << "MATCH"
      else
        raise "Illegal state type: #{state_byte}"
      end

      builder << "\n"
      builder.to_s
    end

    def format_address(address : Int32) : String
      sprintf("%4d:", address)
    end

    def format_arcs(fst : Bytes, address : Int32, accumulate_bytes : Int32, jump_bytes : Int32) : String
      builder = String::Builder.new
      arcs = Bits.get_short(fst, address)
      address -= 2

      arcs.times do |i|
        builder << format_address(address)
        builder << format_arc(fst, address, accumulate_bytes, jump_bytes)
        builder << "\n"
        address -= 2 + accumulate_bytes + jump_bytes
      end

      builder.to_s
    end

    def format_arc(fst : Bytes, address : Int32, accumulate_bytes : Int32, jump_bytes : Int32) : String
      builder = String::Builder.new

      output = Bits.get_int(fst, address, accumulate_bytes)
      address -= accumulate_bytes

      jump_address = Bits.get_int(fst, address, jump_bytes)
      address -= jump_bytes

      label = Bits.get_short(fst, address).chr

      builder << "\t"
      builder << label
      builder << " -> "
      builder << output
      builder << "\t(JMP: "
      builder << jump_address
      builder << ")"

      builder.to_s
    end

    # 辅助方法 - 从字节数组中读取指定位置的字节
    private def get_byte(bytes : Bytes, index : Int32) : UInt8
      bytes[index]
    end

    # 辅助方法 - 从字节数组中读取 Int16（假设为大端序）
    private def get_short(bytes : Bytes, index : Int32) : Int16
      high = bytes[index].to_i16
      low = bytes[index + 1].to_i16
      (high << 8) | low
    end

    # 辅助方法 - 从字节数组中读取指定字节数的整数（假设为大端序）
    private def get_int(bytes : Bytes, index : Int32, byte_count : Int32) : Int32
      result = 0
      byte_count.times do |i|
        # puts "index = #{index}, i = #{i}, Byte = #{bytes[index - i]}"
        result = (result << 8) | bytes[index - i]
      end
      result
    end
  end
end
