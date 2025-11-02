module CrystalMoji::Dict
  abstract class DictionaryEntryBase
    getter surface : String
    getter left_id : Int16
    getter right_id : Int16
    getter word_cost : Int16

    def initialize(@surface, @left_id, @right_id, word_cost)
      @word_cost = clamp_to_int16(word_cost)
    end

    private def clamp_to_int16(value : Int32) : Int16
      if value < Int16::MIN
        Int16::MIN
      elsif value > Int16::MAX
        Int16::MAX
      else
        value.to_i16
      end
    end

    def to_s
      "#{surface}, #{left_id}, #{right_id}, #{word_cost}"
    end
  end
end
