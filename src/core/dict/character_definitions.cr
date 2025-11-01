require "../iio/integer_array_io"
require "../iio/string_array_io"

module CrystalMoji::Dict
  class CharacterDefinitions
    class_property character_definitions_filename : String = "characterDefinitions.bin"
    class_property invoke : Int32 = 0
    class_property group : Int32 = 1
    class_property length : Int32 = 2 # Not used as of now

    @@default_category : String = "DEFAULT"

    @category_definitions : Array(Array(Int32))
    @codepoint_mappings : Array(Array(Int32)?)
    @category_symbols : Array(String)
    @default_category : Array(Int32)

    def initialize(@category_definitions, @codepoint_mappings, @category_symbols)
      @default_category = lookup_categories([@@default_category])
    end

    def lookup_categories(char : Char) : Array(Int32)
      codepoint = char.ord
      mappings = @codepoint_mappings[codepoint]
      mappings || @default_category
    end

    def lookup_definition(category : Int32) : Array(Int32)
      @category_definitions[category]
    end

    def self.new_instance(resolver : ResourceResolver) : CharacterDefinitions
      io = resolver.resolve(character_definitions_filename)

      begin
        definitions = CrystalMoji::IIO::IntegerArrayIO.read_sparse_array_2d(io)
        mappings = CrystalMoji::IIO::IntegerArrayIO.read_sparse_array_2d(io)
        symbols = CrystalMoji::IIO::StringArrayIO.read_array(io)

        CharacterDefinitions.new(definitions, mappings, symbols)
      ensure
        io.close
      end
    end

    def set_categories(char : Char, category_names : Array(String)) : Nil
      codepoint = char.ord
      @codepoint_mappings[codepoint] = lookup_categories(category_names)
    end

    private def lookup_categories(category_names : Array(String)) : Array(Int32)
      categories = Array(Int32).new(category_names.size)

      category_names.each do |category|
        category_index = @category_symbols.index(category)

        if category_index.nil?
          raise "No category '#{category}' found"
        end

        categories << category_index
      end

      categories
    end

  end
end
