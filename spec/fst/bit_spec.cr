require "../spec_helper"

describe Crystalmoji do
  bytes = Slice[90_u8, (-1 & 0xFF).to_u8, 0_u8, 0_u8, 0_u8, (-112 & 0xFF).to_u8, 0_u8, 0_u8, 0_u8, 6_u8, 0_u8, 5_u8, 1_u8]
  puts "1 => #{CrystalMoji::FST::Bits.get_byte(bytes, bytes.size - 1)}"
  puts "5 => #{CrystalMoji::FST::Bits.get_short(bytes, bytes.size - (1 + 1))}"
  puts "6 => #{CrystalMoji::FST::Bits.get_int(bytes, bytes.size - (1 + 1 + 2))}"
  puts "144 => #{CrystalMoji::FST::Bits.get_int(bytes, bytes.size - (1 + 1 + 2 + 4))}"
end
