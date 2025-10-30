require "../spec_helper"

describe Crystalmoji do

  input_values = ["cat", "cats", "dog", "dogs", "friday", "friend", "padata"]
  output_values = [0, 1, 2, 3, 4, 20, 42]

  builder = CrystalMoji::FST::Builder.new
  builder.build(input_values, output_values)

  fst_formatter = CrystalMoji::FST::FSTFormatter.new
  fst_formatter.format(builder, "LinearSearchFiniteStateTransducerOutput.txt")

end
