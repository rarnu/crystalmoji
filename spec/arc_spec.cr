require "./spec_helper"

describe Crystalmoji do
  st = CrystalMoji::FST::State.new
  arc = CrystalMoji::FST::Arc.new(st)
  arc2 = CrystalMoji::FST::Arc.new(0, st, 'a')
  puts arc
  puts arc2
  puts arc == arc2
  puts arc.hash
  puts arc2.hash

end
