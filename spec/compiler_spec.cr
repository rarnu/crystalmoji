require "./spec_helper"

describe Crystalmoji do
  fc = CrystalMoji::FST::Compiler.new
  st = CrystalMoji::FST::State.new
  fc.compile_state(st)

  puts fc.get_bytes
end
