require "./spec_helper"

describe Crystalmoji do
  m = IO::Memory.new
  m.write_byte 0
  m << 0
  m.rewind
  b = m.getb_to_end
  puts b.to_s
end
