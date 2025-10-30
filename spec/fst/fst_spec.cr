require "../spec_helper"

describe Crystalmoji do
  input_values = ["brats", "cat", "dog", "dogs", "rat"]
  output_values = [1, 3, 5, 7, 11]

  builder = CrystalMoji::FST::Builder.new
  builder.build(input_values, output_values)

  input_values.each_index do |i|
    output_values[i].should eq(builder.transduce(input_values[i]))
  end

  compiled_fst = builder.get_compiler
  fst = CrystalMoji::FST::FST.new(compiled_fst.get_bytes)

  puts "0 => #{fst.lookup("brat")}"
  puts "1 => #{fst.lookup("brats")}"
  puts "3 => #{fst.lookup("cat")}"
  puts "5 => #{fst.lookup("dog")}"
  puts "7 => #{fst.lookup("dogs")}"
  puts "11 => #{fst.lookup("rat")}"
  puts "-1 => #{fst.lookup("rats")}"

end

