require "./spec_helper"

describe Crystalmoji do
  t_start = Time.monotonic.total_nanoseconds
  puts t_start

  input_values = ["cat", "cats", "dog", "dogs", "friday", "friend", "pydata"]
  output_values = [1, 2, 3, 4, 20, 42, 43]

  builder = CrystalMoji::FST::Builder.new
  builder.build(input_values, output_values)

  0.upto(input_values.size - 1) do |i|
    puts "outputValues[i] = #{output_values[i]}, transduce[i] = #{builder.transduce(input_values[i])}"
    output_values[i].should eq(builder.transduce(input_values[i]))
  end

  t_end = Time.monotonic.total_nanoseconds
  puts t_end

  puts t_end - t_start
end
