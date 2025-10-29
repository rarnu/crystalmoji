require "../spec_helper"

describe Crystalmoji do
  formatter = CrystalMoji::FST::BitsFormatter.new
  input_values = ["cat", "cats", "rats"]
  output_values = [10, 20, 30]

  builder =  CrystalMoji::FST::Builder.new
  builder.build(input_values, output_values)

  compiled_fst = builder.get_compiler

  b = compiled_fst.get_bytes

  fmts = formatter.format(compiled_fst.get_bytes)
  puts fmts

        # assertEquals("" +
        #     "  50: MATCH\n" +
        #     "  47:\tr -> 30\t(JMP: 39)\n" +
        #     "  43:\tc -> 10\t(JMP: 21)\n" +
        #     "  39: MATCH\n" +
        #     "  36:\ta -> 0\t(JMP: 33)\n" +
        #     "  33: MATCH\n" +
        #     "  30:\tt -> 0\t(JMP: 27)\n" +
        #     "  27: MATCH\n" +
        #     "  24:\ts -> 0\t(JMP: 2)\n" +
        #     "  21: MATCH\n" +
        #     "  18:\ta -> 0\t(JMP: 15)\n" +
        #     "  15: MATCH\n" +
        #     "  12:\tt -> 0\t(JMP: 9)\n" +
        #     "   9: ACCEPT\n" +
        #     "   6:\ts -> 10\t(JMP: 2)\n" +
        #     "   2: ACCEPT\n",
        #     formatter.format(compiledFST.getBytes())
        # );
end
