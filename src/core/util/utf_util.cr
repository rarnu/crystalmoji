module CrystalMoji::Util
  class UTFUtil
    def self.read_utf(io : IO) : String
      length = read_unsigned_short(io)
      bytes = Bytes.new(length)
      io.read_fully(bytes)
      decode_modified_utf8(bytes)
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
              if code_point <= 0x7FF
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

            if code_point <= 0xFFFF
              str << code_point.unsafe_chr
            else
              str << '\uFFFD'
            end
            i += 3
          elsif (byte & 0xF8) == 0xF0 && i + 3 < bytes.size
            byte2 = bytes[i + 1]
            byte3 = bytes[i + 2]
            byte4 = bytes[i + 3]
            code_point = ((byte & 0x07) << 18) | ((byte2 & 0x3F) << 12) | ((byte3 & 0x3F) << 6) | (byte4 & 0x3F)

            if code_point <= 0x10FFFF
              if code_point > 0xFFFF
                code_point -= 0x10000
                high_surrogate = 0xD800 + (code_point >> 10)
                low_surrogate = 0xDC00 + (code_point & 0x3FF)

                str << high_surrogate.unsafe_chr
                str << low_surrogate.unsafe_chr
              else
                str << code_point.unsafe_chr
              end
            else
              str << '\uFFFD'
            end
            i += 4
          else
            str << '\uFFFD'
            i += 1
          end
        end
      end
    end

    private def self.encode_modified_utf8(string : String) : Bytes
      # 使用 IO::Memory 作为缓冲区
      buffer = IO::Memory.new

      string.each_char do |char|
        codepoint = char.ord

        # 特殊处理 null 字符 (U+0000)
        if codepoint == 0
          buffer.write_byte(0xC0_u8)
          buffer.write_byte(0x80_u8)
          # 单字节字符 (U+0001 到 U+007F)
        elsif codepoint <= 0x7F
          buffer.write_byte(codepoint.to_u8)
          # 双字节字符 (U+0080 到 U+07FF)
        elsif codepoint <= 0x7FF
          buffer.write_byte((0xC0 | (codepoint >> 6)).to_u8)
          buffer.write_byte((0x80 | (codepoint & 0x3F)).to_u8)
          # 三字节字符 (U+0800 到 U+FFFF)
        elsif codepoint <= 0xFFFF
          # 检查是否是 UTF-16 代理对的高代理项
          if 0xD800 <= codepoint && codepoint <= 0xDBFF
            # 这是一个代理对，需要特殊处理
            # 在实际实现中，我们需要处理完整的代理对
            # 这里简化处理，使用替换字符
            buffer.write_byte(0xEF_u8)
            buffer.write_byte(0xBF_u8)
            buffer.write_byte(0xBD_u8)
            # 检查是否是 UTF-16 代理对的低代理项
          elsif 0xDC00 <= codepoint && codepoint <= 0xDFFF
            # 这是一个低代理项，不应该单独出现
            buffer.write_byte(0xEF_u8)
            buffer.write_byte(0xBF_u8)
            buffer.write_byte(0xBD_u8)
          else
            # 正常的三字节字符
            buffer.write_byte((0xE0 | (codepoint >> 12)).to_u8)
            buffer.write_byte((0x80 | ((codepoint >> 6) & 0x3F)).to_u8)
            buffer.write_byte((0x80 | (codepoint & 0x3F)).to_u8)
          end
          # 四字节字符 (U+10000 到 U+10FFFF)
        else
          # 转换为 UTF-16 代理对
          codepoint -= 0x10000
          high_surrogate = 0xD800 + (codepoint >> 10)
          low_surrogate = 0xDC00 + (codepoint & 0x3FF)

          # 编码高代理项
          buffer.write_byte((0xE0 | (high_surrogate >> 12)).to_u8)
          buffer.write_byte((0x80 | ((high_surrogate >> 6) & 0x3F)).to_u8)
          buffer.write_byte((0x80 | (high_surrogate & 0x3F)).to_u8)

          # 编码低代理项
          buffer.write_byte((0xE0 | (low_surrogate >> 12)).to_u8)
          buffer.write_byte((0x80 | ((low_surrogate >> 6) & 0x3F)).to_u8)
          buffer.write_byte((0x80 | (low_surrogate & 0x3F)).to_u8)
        end
      end

      buffer.to_slice
    end
  end
end
