require "./compiler"
require "../iio/byte_buffer_io"

module CrystalMoji::Compile
  class FSTCompiler
    include Compiler

    @output : IO
    @surfaces : Array(String)

    def initialize(@output, surfaces : Array(String))
      @surfaces = surfaces.to_set.to_a
    end

    def compile
      @surfaces.sort!
      builder = Builder.new
      builder.build(@surfaces, nil)
      fst = Slice.new(builder.compiler.bytes)
      CrystalMoji::IIO::ByteBufferIO.write(@output, fst)
    end
  end
end
