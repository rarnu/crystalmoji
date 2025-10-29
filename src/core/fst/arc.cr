require "./state"

module CrystalMoji::FST
  class Arc
    property label : Char = '\0'
    property output : Int32 = 0

    @destination : State

    def initialize(@output, @destination, @label)
    end

    def initialize(@destination)
    end

    def get_destination
      @destination
    end

    def ==(other : Arc) : Bool
      return false unless other.is_a?(Arc)
      if @label != other.label
        return false
      end
      if @output != other.@output
        return false
      end
      if @destination != other.@destination
        return false
      end
      return true
    end

    def hash : Int32
      result = @label.ord.to_u64
      result = 3_u64 &* result &+ @output.to_u64
      result = 3_u64 &* result &+ @destination.hash.to_u64
      (result & 0xFFFFFFFF).to_i32!
    end

    def to_s : String
      "Arc(label: #{@label}, output: #{@output}, destination: #{@destination})"
    end
  end
end
