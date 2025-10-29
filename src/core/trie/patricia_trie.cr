module CrystalMoji::Trie
  class PatriciaTrie(V) < Hash(String, V?)



    def [](key : String) : V?
      has_key?(key) ? super : nil
    end

    def <<(m : Hash(String, V?))
      m.each do |k, v|
        self[k] = v
      end
    end

    def contains_key_prefix?(prefix : String) : Bool
      if prefix == ""
        return true
      end
      self.each do |k, v|
        if k.starts_with?(prefix)
          return true
        end
      end
      return false
    end
  end

  module KeyMapper(K)
    abstract def set?(bit : Int, key : K) : Bool
    abstract def to_bit_string(key : K) : String
  end

  class StringKeyMapper
    include KeyMapper(String)

    @@character_size : Int32 = 16

    def set?(bit : Int, key : String?) : Bool
      return false if key.nil?
      return true if bit >= length(key)

      char_index = bit // @@character_size
      code_point = key[char_index].ord
      mask = 1 << (@@character_size - 1 - (bit % @@character_size))
      result = code_point & mask

      result != 0
    end

    def to_bit_string(key : String?) : String
      return "" if key.nil?

      builder = String::Builder.new
      length(key).times do |i|
        builder << set?(i, key) ? "1" : "0"

        if (i + 1) % 4 == 0 && i < length(key) - 1
          builder << " "
        end
      end
      builder.to_s
    end

    private def length(key : String?) : Int32
      key.nil? ? 0 : key.size * 16
    end
  end
end
