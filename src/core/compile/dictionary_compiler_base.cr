module CrystalMoji::Compile
  abstract class DictionaryCompilerBase
    def build(input_dirname : String, output_dirname : String, encoding : String)
      # 创建输出目录
      Dir.mkdir_p(output_dirname)

      build_token_info_dictionary(input_dirname, output_dirname, encoding)
      build_unknown_word_dictionary(input_dirname, output_dirname, encoding)
      build_connection_costs(input_dirname, output_dirname)
    end

    private def build_token_info_dictionary(input_dirname : String, output_dirname : String, encoding : String)
      ProgressLog.begin("compiling tokeninfo dict")
      token_info_compiler = get_token_info_dictionary_compiler(encoding)

      ProgressLog.println("analyzing dictionary features")
      token_info_compiler.analyze_token_info(
        token_info_compiler.combined_sequential_file_input_stream(File.new(input_dirname))
      )

      ProgressLog.println("reading tokeninfo")
      token_info_compiler.read_token_info(
        token_info_compiler.combined_sequential_file_input_stream(File.new(input_dirname))
      )

      token_info_compiler.compile

      surfaces = token_info_compiler.surfaces

      ProgressLog.begin("compiling fst")

      fst_compiler = FSTCompiler.new(
        IO::Buffered.new(File.open(File.join(output_dirname, FST::FST_FILENAME), "w")),
        surfaces
      )

      fst_compiler.compile

      ProgressLog.println("validating saved fst")

      fst = FST.new(IO::Buffered.new(File.open(File.join(output_dirname, FST::FST_FILENAME), "r")))

      surfaces.each do |surface|
        if fst.lookup(surface) < 0
          ProgressLog.println("failed to look up [#{surface}]")
        end
      end

      ProgressLog.end

      ProgressLog.begin("processing target map")

      surfaces.each_with_index do |surface, i|
        id = fst.lookup(surface)
        raise "Invalid ID for surface #{surface}" if id <= 0
        token_info_compiler.add_mapping(id, i)
      end

      token_info_compiler.write(output_dirname)
      ProgressLog.end

      ProgressLog.end
    end

    abstract def get_token_info_dictionary_compiler(encoding : String) : TokenInfoDictionaryCompilerBase

    protected def build_unknown_word_dictionary(input_dirname : String, output_dirname : String, encoding : String)
      ProgressLog.begin("compiling unknown word dict")

      char_def_compiler = CharacterDefinitionsCompiler.new(
        IO::Buffered.new(File.open(File.join(output_dirname, CharacterDefinitions::CHARACTER_DEFINITIONS_FILENAME), "w"))
      )

      char_def_compiler.read_character_definition(
        IO::Buffered.new(File.open(File.join(input_dirname, "char.def"), "r")),
        encoding
      )
      char_def_compiler.compile

      unk_def_compiler = UnknownDictionaryCompiler.new(
        char_def_compiler.make_character_category_map,
        File.open(File.join(output_dirname, UnknownDictionary::UNKNOWN_DICTIONARY_FILENAME), "w")
      )

      unk_def_compiler.read_unknown_definition(
        IO::Buffered.new(File.open(File.join(input_dirname, "unk.def"), "r")),
        encoding
      )

      unk_def_compiler.compile

      ProgressLog.end
    end

    private def build_connection_costs(input_dirname : String, output_dirname : String)
      ProgressLog.begin("compiling connection costs")

      connection_costs_compiler = ConnectionCostsCompiler.new(
        File.open(File.join(output_dirname, ConnectionCosts::CONNECTION_COSTS_FILENAME), "w")
      )

      connection_costs_compiler.read_costs(
        File.open(File.join(input_dirname, "matrix.def"), "r")
      )

      connection_costs_compiler.compile

      ProgressLog.end
    end

    protected def build(args : Array(String))
      if args.size < 3
        raise ArgumentError.new("Expected 3 arguments: input_dirname, output_dirname, input_encoding")
      end

      input_dirname = args[0]
      output_dirname = args[1]
      input_encoding = args[2]

      ProgressLog.println("dictionary compiler")
      ProgressLog.println("")
      ProgressLog.println("input directory: #{input_dirname}")
      ProgressLog.println("output directory: #{output_dirname}")
      ProgressLog.println("input encoding: #{input_encoding}")
      ProgressLog.println("")

      build(input_dirname, output_dirname, input_encoding)
    end
  end
end
