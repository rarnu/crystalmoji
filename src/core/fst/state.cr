require "./arc"

module CrystalMoji::FST
  class State
    property arcs : Array(Arc)

    @is_final : Bool = false

    property visited : Bool = false

    property target_jump_address : Int32 = -1

    def initialize
      @arcs = [] of Arc
    end

    def initialize(source : State)
      @arcs = source.arcs
      @is_final = source.@is_final
    end

    def set_arc(transition : Char, output : Int32, toState : State) : Arc
      new_arc = Arc.new(output, toState, transition)
      @arcs << new_arc
      new_arc
    end

    def set_arc(transition : Char, toState : State)
      new_arc = Arc.new(toState)
      new_arc.label = transition
      @arcs << new_arc
    end

    def get_all_transition_strings : Array(Char)
      ret_list = [] of Char
      @arcs.each do |arc|
        ret_list.add(arc.label)
      end
      ret_list.sort
      ret_list
    end

    def set_final
      @is_final = true
    end

    def is_final : Bool
      @is_final
    end

    def find_arc(transition : Char) : Arc?
      binary_search_arc(transition, 0, @arcs.size)
    end

    def binary_search_arc(transition : Char, begin_indice : Int32, end_indice : Int32) : Arc?
      if begin_indice >= end_indice
        return nil
      end

      indice = (begin_indice + (end_indice - begin_indice) / 2).to_i32
      if @arcs[indice].label == transition
        return @arcs[indice]
      elsif @arcs[indice].label > transition
        return binary_search_arc(transition, begin_indice, indice)
      elsif @arcs[indice].label < transition
        return binary_search_arc(transition, indice + 1, end_indice)
      end
      return nil
    end

    def ==(other : State) : Bool
      return false unless other.is_a?(State)
      if @is_final != other.@is_final
        return false
      end
      if @arcs != other.@arcs
        return false
      end
      return true
    end

    def hash : Int32
      result : UInt64 = 0
      @arcs.each do |arc|
        result = 3_u64 &* result &+ arc.hash.to_u64
      end
      result = 3_u64 &* result &+ (@is_final ? 1_u64 : 0_u64)
      (result & 0xFFFFFFFF).to_i32!
    end

    def to_s : String
      "State(arcs: #{@arcs.to_s}, is_final: #{@is_final})"
    end
  end
end
