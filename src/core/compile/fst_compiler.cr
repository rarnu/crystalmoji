require "./compiler"

module CrystalMoji::Compile
  class FSTCompiler
    include Compiler

    @output : IO
    @surfaces : Array(String)

    def initialize(@output, @surfaces)
    end

    def compile
      surfaces.sort
    end
  end
end

# public class FSTCompiler implements Compiler {

#     @Override
#     public void compile() throws IOException {
#         Arrays.sort(surfaces);

#         Builder builder = new Builder();
#         builder.build(surfaces, null) ;

#         ByteBuffer fst = ByteBuffer.wrap(
#             builder.getCompiler().getBytes()
#         );

#         ByteBufferIO.write(output, fst);
#     }
# }
