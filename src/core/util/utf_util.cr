module CrystalMoji::Util
  class UTFUtil
    def self.read_utf(io : IO) : String
      length = read_unsigned_short(io)
      bytes = Bytes.new(length)
      io.read_fully(bytes)
      # decode_modified_utf8(bytes)
      String.new(bytes)
    end

    def self.write_utf(io : IO, string : String)
      bytes = encode_modified_utf8(string)
      write_unsigned_short(io, bytes.size.to_u16)
      io.write(bytes)
    end

    private def self.read_unsigned_short(io : IO) : UInt16
      byte1 = io.read_byte.not_nil!.to_u16
      byte2 = io.read_byte.not_nil!.to_u16
      (byte1 << 8) | byte2
    end

    private def self.write_unsigned_short(io : IO, value : UInt16)
      io.write_byte((value >> 8).to_u8)
      io.write_byte((value & 0xFF).to_u8)
    end

    private def self.decode_modified_utf8(bytes : Bytes) : String
      String.build do |str|
        i = 0
        while i < bytes.size
          byte = bytes[i]

          if byte == 0
            str << '\u0000'
            i += 1
          elsif (byte & 0x80) == 0
            str.write_byte(byte)
            i += 1
          elsif (byte & 0xE0) == 0xC0 && i + 1 < bytes.size
            byte2 = bytes[i + 1]
            if byte == 0xC0 && byte2 == 0x80
              str << '\u0000'
            else
              code_point = ((byte & 0x1F) << 6) | (byte2 & 0x3F)
              if code_point >= 0x80 && code_point <= 0x7FF
                str << code_point.unsafe_chr
              else
                str << '\uFFFD'
              end
            end
            i += 2
          elsif (byte & 0xF0) == 0xE0 && i + 2 < bytes.size
            byte2 = bytes[i + 1]
            byte3 = bytes[i + 2]
            code_point = ((byte & 0x0F) << 12) | ((byte2 & 0x3F) << 6) | (byte3 & 0x3F)

            # Check for valid 3-byte sequence range
            if code_point >= 0x800 && code_point <= 0xFFFF &&
               !(code_point >= 0xD800 && code_point <= 0xDFFF)
              str << code_point.unsafe_chr
            elsif code_point >= 0xD800 && code_point <= 0xDFFF
              # Handle potential surrogate pairs - check if this is a high surrogate
              # followed by a low surrogate
              if code_point >= 0xD800 && code_point <= 0xDBFF &&
                 i + 5 < bytes.size &&
                 (bytes[i+3] & 0xF0) == 0xE0  # Next char is also 3-byte

                next_byte1 = bytes[i+3]
                next_byte2 = bytes[i+4]
                next_byte3 = bytes[i+5]

                low_surrogate = ((next_byte1 & 0x0F) << 12) |
                               ((next_byte2 & 0x3F) << 6) |
                               (next_byte3 & 0x3F)

                if low_surrogate >= 0xDC00 && low_surrogate <= 0xDFFF
                  # Valid surrogate pair
                  code_point = 0x10000 +
                              ((code_point & 0x3FF) << 10) +
                              (low_surrogate & 0x3FF)
                  str << code_point.chr
                  i += 6
                  next
                else
                  str << '\uFFFD'
                end
              else
                str << '\uFFFD'
              end
            else
              str << '\uFFFD'
            end
            i += 3
          else
            str << '\uFFFD'
            i += 1
          end
        end
      end
    end

    private def self.encode_modified_utf8(string : String) : Bytes
      buffer = IO::Memory.new

      string.each_char_with_index do |char, index|
        codepoint = char.ord

        # Special handling for null character (U+0000)
        if codepoint == 0
          buffer.write_byte(0xC0_u8)
          buffer.write_byte(0x80_u8)
        # Single byte characters (U+0001 to U+007F)
        elsif codepoint <= 0x7F
          buffer.write_byte(codepoint.to_u8)
        # Two byte characters (U+0080 to U+07FF)
        elsif codepoint <= 0x7FF
          buffer.write_byte((0xC0 | (codepoint >> 6)).to_u8)
          buffer.write_byte((0x80 | (codepoint & 0x3F)).to_u8)
        # Three byte characters (U+0800 to U+FFFF), excluding surrogates
        elsif codepoint <= 0xFFFF && !(codepoint >= 0xD800 && codepoint <= 0xDFFF)
          buffer.write_byte((0xE0 | (codepoint >> 12)).to_u8)
          buffer.write_byte((0x80 | ((codepoint >> 6) & 0x3F)).to_u8)
          buffer.write_byte((0x80 | (codepoint & 0x3F)).to_u8)
        # Handle surrogate pairs properly
        elsif codepoint >= 0x10000 && codepoint <= 0x10FFFF
          # Convert to UTF-16 surrogate pair
          adjusted = codepoint - 0x10000
          high_surrogate = 0xD800 + ((adjusted >> 10) & 0x3FF)
          low_surrogate = 0xDC00 + (adjusted & 0x3FF)

          # Encode high surrogate
          buffer.write_byte((0xE0 | (high_surrogate >> 12)).to_u8)
          buffer.write_byte((0x80 | ((high_surrogate >> 6) & 0x3F)).to_u8)
          buffer.write_byte((0x80 | (high_surrogate & 0x3F)).to_u8)

          # Encode low surrogate
          buffer.write_byte((0xE0 | (low_surrogate >> 12)).to_u8)
          buffer.write_byte((0x80 | ((low_surrogate >> 6) & 0x3F)).to_u8)
          buffer.write_byte((0x80 | (low_surrogate & 0x3F)).to_u8)
        else
          # Invalid code points including unpaired surrogates
          buffer.write_byte(0xEF_u8)
          buffer.write_byte(0xBF_u8)
          buffer.write_byte(0xBD_u8) # Replacement character
        end
      end

      buffer.to_slice
    end
  end
end
