require "./state"
require "./arc"

module CrystalMoji::FST
  class Compiler
    @@STATE_TYPE_MATCH = 0x00_u8
    @@STATE_TYPE_ACCEPT = 0x80_u8
    @written = 0_i32
    @data_output : IO
    @written = 0_i32

    def initialize
      @data_output = IO::Memory.new
    end

    def compile_state(state : State)
      if state.target_jump_address == -1
        jump_bytes = self.find_max_jump_address_bytes(state)
        output_bytes = self.find_max_output_bytes(state)

        self.write_state_arcs(state, output_bytes, jump_bytes)
        self.write_state_type(state, output_bytes, jump_bytes)

        state.target_jump_address = @written - 1
      end
    end

    private def find_max_jump_address_bytes(state : State) : Int32
      max_jump_address = 0
      state.arcs.each do |arc|
        jump_address = arc.get_destination.target_jump_address
        if max_jump_address < jump_address
          max_jump_address = jump_address
        end
      end
      find_bytes(max_jump_address)
    end

    private def find_bytes(value : Int32) : Int32
      if value < 256
        return 1
      end

      if value < 65536
        return 2
      end

      if value < 16777216
        return 3
      end

      return 4
    end

    private def find_max_output_bytes(state : State) : Int32
      max_output = 0
      state.arcs.each do |arc|
        output = arc.output
        if max_output < output
          max_output = output
        end
      end

      if max_output == 0
        return 0
      end
      find_bytes(max_output)
    end

    private def write_state_arcs(state : State, output_bytes : Int32, jump_bytes : Int32)
      arcs = state.arcs
      state.arcs.each do |arc|
        write_state_arc(arc, output_bytes, jump_bytes)
      end
      @data_output << arcs.size
      @written += 2
    end

    private def write_state_arc(arc : Arc, output_bytes : Int32, jump_bytes : Int32)
      target = arc.get_destination
      arc_size = 2 + jump_bytes + output_bytes
      @data_output << arc.label

      write_int_value(target.target_jump_address, jump_bytes)
      write_int_value(arc.output, output_bytes)

      @written += arc_size
    end

    private def write_int_value(value : Int32, bytes : Int32)
      case bytes
      when 0
      when 1
        @data_output << (value & 0xff_u8)
      when 2
        @data_output << ((value >> 8) & 0xff_u8)
        @data_output << (value & 0xff_u8)
      when 3
        @data_output << ((value >> 16) & 0xff_u8)
        @data_output << ((value >> 8) & 0xff_u8)
        @data_output << (value & 0xff_u8)
      when 4
        @data_output << ((value >> 24) & 0xff_u8)
        @data_output << ((value >> 16) & 0xff_u8)
        @data_output << ((value >> 8) & 0xff_u8)
        @data_output << (value & 0xff_u8)
      else
        raise "Illegal int byte size: #{bytes}"
      end
    end

    private def write_state_type(state : State, output_bytes : Int32, jump_bytes : Int32)
      state_type : UInt8 = state.is_final ? @@STATE_TYPE_ACCEPT : @@STATE_TYPE_MATCH
      state_type |= (jump_bytes - 1)
      state_type |= (output_bytes << 3)
      @data_output << state_type
      @written += 1
    end

    def get_bytes : Array(UInt8)
      # byteArrayOutput.toByteArray();
      @data_output.rewind
      @data_output.getb_to_end.to_a
    end
  end
end
