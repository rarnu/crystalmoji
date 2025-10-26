require "./spec_helper"

describe Crystalmoji do

  st = CrystalMoji::FST::State.new
  st2 = CrystalMoji::FST::State.new(st)

  puts st == st2
  puts st.hash
end
