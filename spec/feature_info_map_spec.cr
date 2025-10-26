require "./spec_helper"

describe Crystalmoji do
  fim = CrystalMoji::Buffer::FeatureInfoMap.new
  ids = fim.map_features(["a", "b", "c"])
  puts ids
  ivt = fim.invert()
  puts ivt
  cnt = fim.get_entry_count()
  puts cnt
  puts fim
end
