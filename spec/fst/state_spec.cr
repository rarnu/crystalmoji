require "../spec_helper"

describe Crystalmoji do
  state = CrystalMoji::FST::State.new
  dest_state = CrystalMoji::FST::State.new

  arc_a = state.set_arc('a', 1, dest_state)
  arc_b = state.set_arc('b', 1, dest_state)
  arc_c = state.set_arc('c', 1, dest_state)

  puts "#{arc_a == state.binary_search_arc('a', 0, state.arcs.size)}"
  puts "#{arc_b == state.binary_search_arc('b', 0, state.arcs.size)}"
  puts "#{arc_c == state.binary_search_arc('c', 0, state.arcs.size)}"
  puts "#{state.binary_search_arc('d', 0, state.arcs.size).nil?}"
end

describe Crystalmoji do
  state = CrystalMoji::FST::State.new
  dest_state = CrystalMoji::FST::State.new

  arc_a = state.set_arc('a', 1, dest_state)
  arc_b = state.set_arc('b', 1, dest_state)
  arc_c = state.set_arc('c', 1, dest_state)
  arc_d = state.set_arc('d', 1, dest_state)

  puts "#{arc_a == state.find_arc('a')}"
  puts "#{arc_b == state.find_arc('b')}"
  puts "#{arc_c == state.find_arc('c')}"
  puts "#{arc_d == state.find_arc('d')}"
end

describe Crystalmoji do
  state = CrystalMoji::FST::State.new
  dest_state = CrystalMoji::FST::State.new

  arc_a = state.set_arc('a', 1, dest_state)
  arc_b = state.set_arc('b', 1, dest_state)
  arc_c = state.set_arc('c', 1, dest_state)

  surrogate_one = '𥝱' # U+25771
  arc_d = state.set_arc(surrogate_one, 1, dest_state)

  puts "#{arc_a == state.find_arc('a')}"
  puts "#{arc_b == state.find_arc('b')}"
  puts "#{arc_d == state.find_arc(surrogate_one)}"
end
