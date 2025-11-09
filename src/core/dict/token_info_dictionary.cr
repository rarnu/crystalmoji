require "./dictionary"
require "../buffer/**"
require "../util/resource_resolver"
require "../util/dictionary_entry_line_parser"

module CrystalMoji::Dict
  class TokenInfoDictionary
    include Dictionary

    class_property token_info_dictionary_filename : String = "tokenInfoDictionary.bin"
    class_property feature_map_filename : String = "tokenInfoFeaturesMap.bin"
    class_property pos_map_filename : String = "tokenInfoPartOfSpeechMap.bin"
    class_property targetmap_filename : String = "tokenInfoTargetMap.bin"

    @@left_id : Int32 = 0
    @@right_id : Int32 = 1
    @@word_cost : Int32 = 2
    @@token_info_offset : Int32 = 3
    @@feature_separator : String = ","

    @token_info_buffer : CrystalMoji::Buffer::TokenInfoBuffer
    @pos_values : CrystalMoji::Buffer::StringValueMapBuffer
    @string_values : CrystalMoji::Buffer::StringValueMapBuffer
    @word_id_map : CrystalMoji::Buffer::WordIdMap

    def lookup_word_ids(source_id : Int32) : Array(Int32)
      @word_id_map.look_up(source_id)
    end

    def get_left_id(word_id : Int32) : Int32
      @token_info_buffer.lookup_token_info(word_id, @@left_id)
    end

    def get_right_id(word_id : Int32) : Int32
      @token_info_buffer.lookup_token_info(word_id, @@right_id)
    end

    def get_word_cost(word_id : Int32) : Int32
      @token_info_buffer.lookup_token_info(word_id, @@word_cost)
    end

    def get_all_features_array(word_id : Int32) : Array(String)
      buffer_entry = @token_info_buffer.lookup_entry(word_id)

      pos_length = buffer_entry.pos_infos.not_nil!.size
      feature_length = buffer_entry.feature_infos.not_nil!.size

      part_of_speech_as_shorts = false

      if pos_length == 0
        pos_length = buffer_entry.token_infos.not_nil!.size - @@token_info_offset
        part_of_speech_as_shorts = true
      end

      result = Array(String).new(pos_length + feature_length)

      if part_of_speech_as_shorts
        (0...pos_length).each do |i|
          feature = buffer_entry.token_infos.not_nil![i + @@token_info_offset]
          result << @pos_values.get(feature)
        end
      else
        (0...pos_length).each do |i|
          feature = buffer_entry.pos_infos.not_nil![i] & 0xff
          result << @pos_values.get(feature)
        end
      end

      (0...feature_length).each do |i|
        feature = buffer_entry.feature_infos.not_nil![i]
        s = @string_values.get(feature)
        result << s
      end

      result
    end

    def get_all_features(word_id : Int32) : String
      features = get_all_features_array(word_id)

      features.map! do |feature|
        CrystalMoji::Util::DictionaryEntryLineParser.escape(feature)
      end

      features.join(@@feature_separator)
    end

    def get_feature(word_id : Int32, *fields : Int32) : String
      if fields.size == 1
        return extract_single_feature(word_id, fields[0])
      end

      extract_multiple_features(word_id, fields.to_a)
    end

    private def extract_single_feature(word_id : Int32, field : Int32) : String
      feature_id : Int32

      if @token_info_buffer.part_of_speech_feature?(field)
        feature_id = @token_info_buffer.lookup_part_of_speech_feature(word_id, field)
        return @pos_values.get(feature_id)
      end

      feature_id = @token_info_buffer.lookup_feature(word_id, field)
      @string_values.get(feature_id)
    end

    private def extract_multiple_features(word_id : Int32, fields : Array(Int32)) : String
      return get_all_features(word_id) if fields.empty?
      return extract_single_feature(word_id, fields[0]) if fields.size == 1

      all_features = get_all_features_array(word_id)
      features = Array(String).new(fields.size)

      fields.each do |field_number|
        feature = all_features[field_number]
        features << CrystalMoji::Util::DictionaryEntryLineParser.escape(feature)
      end

      features.join(@@feature_separator)
    end

    def self.new_instance(resolver : CrystalMoji::Util::ResourceResolver) : TokenInfoDictionary
      TokenInfoDictionary.new(resolver)
    end

    private def setup(resolver : CrystalMoji::Util::ResourceResolver) : Nil
      @token_info_buffer = CrystalMoji::Buffer::TokenInfoBuffer.new(resolver.resolve(TokenInfoDictionary.token_info_dictionary_filename))
      @string_values = CrystalMoji::Buffer::StringValueMapBuffer.new(resolver.resolve(TokenInfoDictionary.feature_map_filename))
      @pos_values = CrystalMoji::Buffer::StringValueMapBuffer.new(resolver.resolve(TokenInfoDictionary.pos_map_filename))
      @word_id_map = CrystalMoji::Buffer::WordIdMap.new(resolver.resolve(TokenInfoDictionary.targetmap_filename))
    end

    def initialize(resolver : CrystalMoji::Util::ResourceResolver)
      @token_info_buffer = CrystalMoji::Buffer::TokenInfoBuffer.new(resolver.resolve(TokenInfoDictionary.token_info_dictionary_filename))
      @string_values = CrystalMoji::Buffer::StringValueMapBuffer.new(resolver.resolve(TokenInfoDictionary.feature_map_filename))
      @pos_values = CrystalMoji::Buffer::StringValueMapBuffer.new(resolver.resolve(TokenInfoDictionary.pos_map_filename))
      @word_id_map = CrystalMoji::Buffer::WordIdMap.new(resolver.resolve(TokenInfoDictionary.targetmap_filename))
    end
  end
end
