module CrystalMoji::FST
  class Bits
    def self.get_byte(array : Slice(UInt8), index : Int32) : UInt8
      array[index]
    end

    def self.get_short(array : Slice(UInt8), index : Int32) : Int32
      (array[index - 1].to_i32 & 0xff) << 8 | (array[index].to_i32 & 0xff)
    end

    def self.get_int(array : Slice(UInt8), index : Int32) : Int32
      (array[index - 3].to_i32 & 0xff) << 24 | (array[index - 2].to_i32 & 0xff) << 16 | (array[index - 1].to_i32 & 0xff) << 8 | (array[index].to_i32 & 0xff)
    end

    def self.get_int(array : Slice(UInt8), index : Int32, int_bytes : Int32) : Int32
      case int_bytes
      when 0
        0
      when 1
        array[index].to_i32 & 0xff
      when 2
        (array[index - 1].to_i32 & 0xff) << 8 | (array[index].to_i32 & 0xff)
      when 3
        (array[index - 2].to_i32 & 0xff) << 16 | (array[index - 1].to_i32 & 0xff) << 8 | (array[index].to_i32 & 0xff)
      when 4
        (array[index - 3].to_i32 & 0xff) << 24 | (array[index - 2].to_i32 & 0xff) << 16 | (array[index - 1].to_i32 & 0xff) << 8 | (array[index].to_i32 & 0xff)
      else
        raise "Illegal int byte size: #{int_bytes}"
      end
    end

    def self.put_int(array : Slice(UInt8), index : Int32, value : Int32, int_bytes : Int32)
      case int_bytes
      when 1
        array[index] = value & 0xff
      when 2
        array[index - 1] = (value >> 8) & 0xff
        array[index] = value & 0xff
      when 3
        array[index - 2] = (value >> 16) & 0xff
        array[index - 1] = (value >> 8) & 0xff
        array[index] = value & 0xff
      when 4
        array[index - 3] = (value >> 24) & 0xff
        array[index - 2] = (value >> 16) & 0xff
        array[index - 1] = (value >> 8) & 0xff
        array[index] = value & 0xff
      else
        raise "Illegal int byte size: #{int_bytes}"
      end
    end
  end
end
