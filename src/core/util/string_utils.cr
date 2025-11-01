module CrystalMoji::Util
  class StringUtils
    def self.get_utf16_surrogates(str : String) : Array(Char)
      result = [] of Char

      str.each_char do |char|
        codepoint = char.ord

        if codepoint > 0xFFFF
          # 计算 UTF-16 代理对
          codepoint -= 0x10000
          high_surrogate = ((codepoint >> 10) + 0xD800).chr
          low_surrogate = ((codepoint & 0x3FF) + 0xDC00).chr

          result << high_surrogate
          result << low_surrogate
        else
          # 基本多文种平面字符
          result << char
        end
      end

      result
    end
  end
end

module StringExtension
  def to_i_0x() : Int32
    self.starts_with?("0x") ? self[2, self.size].to_i(16) : self.to_i(16)
  end
end

class String
  include StringExtension
end
