require "./compiler"
require "../dict/generic_dictionary_entry"
require "../util/unknown_dictionary_entry_parser"
require "../iio/integer_array_io"

module CrystalMoji::Compile
  class UnknownDictionaryCompiler
    include Compiler

    @output : IO
    @category_map : Hash(String, Int32)
    @dictionary_entries = [] of CrystalMoji::Dict::GenericDictionaryEntry

    def initialize(@category_map, @output)
    end

    def read_unknown_definition(input : IO, encoding : String = "UTF-8")
      reader = input
      reader.set_encoding(encoding)

      parser = CrystalMoji::Util::UnknownDictionaryEntryParser.new

      while line = reader.gets
        entry = parser.parse(line)
        @dictionary_entries << entry
      end
    end

    def make_costs : Array(Array(Int32))
      costs = Array(Array(Int32)).new(@dictionary_entries.size)

      @dictionary_entries.each do |entry|
        costs << [entry.left_id.to_i32, entry.right_id.to_i32, entry.word_cost.to_i32]
      end

      costs
    end


    def make_features : Array(Array(String))
      features = Array(Array(String)).new(@dictionary_entries.size)

      @dictionary_entries.each do |entry|
        tmp = [] of String
        # 添加词性特征
        tmp.concat(entry.part_of_speech_features)
        # 添加其他特征
        tmp.concat(entry.other_features)
        features << tmp
      end
      features
    end

    def make_category_references : Array(Array(Int32)?)
      entries = Array(Array(Int32)?).new(@category_map.size, nil)

      @category_map.each do |category, category_id|
        entries[category_id] = get_entry_indices(category)
      end

      entries
    end

    def get_entry_indices(surface : String) : Array(Int32)
      indices = [] of Int32

      @dictionary_entries.each_with_index do |entry, i|
        if entry.surface == surface
          indices << i
        end
      end

      indices
    end

    def get_dictionary_entries : Array(CrystalMoji::Dict::GenericDictionaryEntry)
      @dictionary_entries
    end

    def compile
      CrystalMoji::IIO::IntegerArrayIO.write_array_2d(@output, make_costs)
      CrystalMoji::IIO::IntegerArrayIO.write_array_2d(@output, CrystalMoji::Util::ArrayUtils.no_nil(make_category_references))
      CrystalMoji::IIO::StringArrayIO.write_array_2d(@output, make_features)
      @output.close
    end

  end
end
