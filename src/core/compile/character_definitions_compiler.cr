require "./compiler"
require "../iio/integer_array_io"
require "../iio/string_array_io"
require "../util/for_utils"

module CrystalMoji::Compile
  class CharacterDefinitionsCompiler
    include Compiler

    @category_definitions = Hash(String, Array(Int32)).new
    @codepoint_categories = Array(Set(String)?).new(65536, nil)
    @output : IO

    def initialize(@output)
    end

    def read_character_definition(stream : IO, encoding : String = "UTF-8")
      reader = stream
      reader.set_encoding(encoding)

      while line = reader.gets
        # Strip comments
        line = line.gsub(/\s*#.*/, "")

        # Skip empty line or comment line
        next if line.empty?

        if category_entry?(line)
          parse_category(line)
        else
          parse_mapping(line)
        end
      end
    end

    private def parse_category(line : String)
      values = line.split(/\s+/)

      classname = values[0]
      invoke = values[1].to_i
      group = values[2].to_i
      length = values[3].to_i

      raise "Category #{classname} already defined" if @category_definitions.has_key?(classname)

      @category_definitions[classname] = [invoke, group, length]
    end

    private def parse_mapping(line : String)
      values = line.split(/\s+/)

      raise "Invalid mapping line: #{line}" if values.size < 2

      codepoint_string = values[0]
      categories = get_categories(values)

      if codepoint_string.includes?("..")
        codepoints = codepoint_string.split("..")

        lower_codepoint = codepoints[0].to_i_0x()
        upper_codepoint = codepoints[1].to_i_0x()

        (lower_codepoint..upper_codepoint).each do |i|
          add_mappings(i, categories)
        end
      else
        codepoint = codepoint_string.to_i_0x()
        add_mappings(codepoint, categories)
      end
    end

    private def get_categories(values : Array(String)) : Array(String)
      values[1..].reject(&.empty?)
    end

    private def add_mappings(codepoint : Int32, categories : Array(String))
      categories.each do |category|
        add_mapping(codepoint, category)
      end
    end

    private def add_mapping(codepoint : Int32, category : String)
      categories = @codepoint_categories[codepoint]

      if categories.nil?
        categories = Set(String).new
        @codepoint_categories[codepoint] = categories
      end
      categories.add(category)
    end

    private def category_entry?(line : String) : Bool
      !line.starts_with?("0x")
    end

    def make_character_category_map : Hash(String, Int32)
      class_mapping = Hash(String, Int32).new
      i = 0

      @category_definitions.keys.sort!.each do |category|
        class_mapping[category] = i
        i += 1
      end

      class_mapping
    end

    private def make_character_definitions : Array(Array(Int32)?)
      category_map = make_character_category_map
      size = category_map.size
      array = Array(Array(Int32)?).new(size, nil)

      @category_definitions.keys.sort!.each do |category|
        values = @category_definitions[category]
        raise "Expected 3 values for category #{category}" unless values.size == 3
        index = category_map[category]
        array[index] = values
      end

      array
    end

    private def make_character_mappings : Array(Array(Int32)?)
      category_map = make_character_category_map

      size = @codepoint_categories.size
      array = Array(Array(Int32)?).new(size, nil)

      for i = 0, i < size, i += 1 do
        categories = @codepoint_categories[i]
        if !categories.nil?
          inner_size = categories.size
          inner = Array(Int32).new(inner_size, 0)
          j = 0
          categories.to_a.sort!.each do |value|
            inner[j] = category_map[value]
            j += 1
          end
          array[i] = inner
        end
      end

      array
    end

    private def make_character_category_symbols : Array(String)
      category_map = make_character_category_map
      inverted = Hash(Int32, String).new

      category_map.each do |key, value|
        inverted[value] = key
      end

      categories = Array(String).new(inverted.size)
      inverted.size.times do |index|
        categories << inverted[index]
      end

      categories
    end

    def category_definitions : Hash(String, Array(Int32))
      @category_definitions
    end

    def codepoint_categories : Array(Set(String)?)
      @codepoint_categories
    end

    def compile
      CrystalMoji::IIO::IntegerArrayIO.write_sparse_array_2d(@output, make_character_definitions)
      CrystalMoji::IIO::IntegerArrayIO.write_sparse_array_2d(@output, make_character_mappings)
      CrystalMoji::IIO::StringArrayIO.write_array(@output, make_character_category_symbols)
      @output.close
    end

  end
end
