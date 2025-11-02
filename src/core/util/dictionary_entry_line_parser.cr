module CrystalMoji::Util
  class DictionaryEntryLineParser
    @@quote = '"'
    @@comma = ','
    @@quote_escaped = "\"\""

    def self.parse_line(line : String) : Array(String)
      inside_quote = false
      result = [] of String
      builder = String::Builder.new
      quote_count = 0

      line.each_char do |c|
        if c == @@quote
          inside_quote = !inside_quote
          quote_count += 1
        end

        if c == @@comma && !inside_quote
          value = builder.to_s
          value = unescape(value)

          result << value
          builder = String::Builder.new
          next
        end

        builder << c
      end

      result << builder.to_s

      if quote_count % 2 != 0
        raise "Unmatched quote in entry: #{line}"
      end

      result
    end

    def self.unescape(text : String) : String
      builder = String::Builder.new
      found_quote = false

      text.each_char_with_index do |c, i|
        if (i == 0 && c == @@quote) || (i == text.size - 1 && c == @@quote)
          next
        end

        if c == @@quote
          if found_quote
            builder << @@quote
            found_quote = false
          else
            found_quote = true
          end
        else
          found_quote = false
          builder << c
        end
      end

      builder.to_s
    end

    def self.escape(text : String) : String
      has_quote = text.includes?(@@quote)
      has_comma = text.includes?(@@comma)

      return text unless has_quote || has_comma

      builder = String::Builder.new

      if has_quote
        text.each_char do |c|
          if c == @@quote
            builder << @@quote_escaped
          else
            builder << c
          end
        end
      else
        builder << text
      end

      if has_comma
        builder_string = builder.to_s
        builder = String::Builder.new
        builder << @@quote
        builder << builder_string
        builder << @@quote
      end

      builder.to_s
    end
  end
end
