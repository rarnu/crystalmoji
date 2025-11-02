require "./compiler"
require "./word_id_map_compiler"
require "../dict/generic_dictionary_entry"
require "../buffer/**"

module CrystalMoji::Compile
  abstract class TokenInfoDictionaryCompilerBase(T)

    include Compiler

    property buffer_entries = [] of CrystalMoji::Buffer::BufferEntry
    property pos_info = CrystalMoji::Buffer::FeatureInfoMap.new
    property other_info = CrystalMoji::Buffer::FeatureInfoMap.new
    property word_ids_compiler = CrystalMoji::Compile::WordIdMapCompiler.new
    property dictionary_entries : Array(CrystalMoji::Dict::GenericDictionaryEntry)? = nil
    property surfaces = [] of String

    @encoding : String

    def initialize(@encoding)
    end

    def analyze_token_info(input : IO)
      reader = input
      reader.set_encoding(@encoding)

      reader.each_line do |line|
        entry = parse(line)
        dictionary_entry = make_generic_dictionary_entry(entry)
        pos_info.map_features(dictionary_entry.part_of_speech_features)
      end
    end

    def read_token_info(input : IO)
      reader = input
      reader.set_encoding(@encoding)

      entry_count = pos_info.entry_count

      reader.each_line do |line|
        entry = parse(line)
        dictionary_entry = make_generic_dictionary_entry(entry)

        left_id = dictionary_entry.left_id
        right_id = dictionary_entry.right_id
        word_cost = dictionary_entry.word_cost

        all_pos_features = dictionary_entry.part_of_speech_features
        pos_feature_ids = pos_info.map_features(all_pos_features)

        feature_list = dictionary_entry.other_features
        other_feature_ids = other_info.map_features(feature_list)

        buffer_entry = BufferEntry.new
        buffer_entry.token_info << left_id
        buffer_entry.token_info << right_id
        buffer_entry.token_info << word_cost

        if entries_fit_in_byte?(entry_count)
          pos_feature_id_bytes = create_pos_feature_ids(pos_feature_ids)
          buffer_entry.pos_info.concat(pos_feature_id_bytes)
        else
          pos_feature_ids.each do |pos_feature_id|
            buffer_entry.token_info << pos_feature_id.to_i16
          end
        end

        buffer_entry.features.concat(other_feature_ids)
        buffer_entries << buffer_entry
        surfaces << dictionary_entry.surface

        if dict_entries = @dictionary_entries
          dict_entries << dictionary_entry
        end
      end
    end

    abstract def make_generic_dictionary_entry(entry : T) : CrystalMoji::Dict::GenericDictionaryEntry
    abstract def parse(line : String) : T

    def compile
      # TODO: Should call this method instead of write()
    end

    private def entries_fit_in_byte?(entry_count : Int32) : Bool
      entry_count <= 0xff
    end

    private def create_pos_feature_ids(pos_feature_ids : Array(Int32)) : Array(UInt8)
      # TODO 特别关注
      pos_feature_ids.map { |id| id.to_u8 }
    end

    def combined_sequential_file_input_stream(dir : String) : IO
      files = get_csv_files(dir)
      inputs = files.map { |file| File.open(file, "r") }
      CombinedIO.new(inputs)
    end

    def get_csv_files(dir : String) : Array(String)
      files = Dir.entries(dir)
        .select { |name| name.ends_with?(".csv") }
        .map { |name| File.join(dir, name) }
        .sort

      files
    end

    def add_mapping(source_id : Int32, word_id : Int32)
      word_ids_compiler.add_mapping(source_id, word_id)
    end

    def write(directory_name : String)
      write_dictionary(File.join(directory_name, TokenInfoDictionary::TOKEN_INFO_DICTIONARY_FILENAME))
      write_map(File.join(directory_name, TokenInfoDictionary::POS_MAP_FILENAME), pos_info)
      write_map(File.join(directory_name, TokenInfoDictionary::FEATURE_MAP_FILENAME), other_info)
      write_word_ids(File.join(directory_name, TokenInfoDictionary::TARGETMAP_FILENAME))
    end

    protected def write_map(filename : String, map : FeatureInfoMap)
      features = map.invert
      map_buffer = StringValueMapBuffer.new(features)

      File.open(filename, "w") do |file|
        map_buffer.write(file)
      end
    end

    protected def write_dictionary(filename : String)
      File.open(filename, "w") do |output|
        token_info_buffer_compiler = TokenInfoBufferCompiler.new(output, buffer_entries)
        token_info_buffer_compiler.compile
      end
    end

    protected def write_word_ids(filename : String)
      File.open(filename, "w") do |output|
        word_ids_compiler.write(output)
      end
    end

  end


  class CombinedIO < IO
    def initialize(@inputs : Array(IO))
      @current_index = 0
    end

    def read(slice : Bytes)
      while @current_index < @inputs.size
        bytes_read = @inputs[@current_index].read(slice)
        return bytes_read if bytes_read > 0
        @current_index += 1
      end
      0
    end

    def write(slice : Bytes) : Nil
      raise "Not implemented"
    end

    def close
      @inputs.each(&.close)
    end
  end

end
