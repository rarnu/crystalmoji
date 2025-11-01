require "./dictionary"
require "./character_definitions"
require "../buffer/**"
require "../util/resource_resolver"

module CrystalMoji::Dict
  class UnknownDictionary
    include Dictionary

    class_property unknown_dictionary_filename : String = "unknownDictionary.bin"

    @@default_feature = "*"
    @@feature_separator = ","

    @entries : Array(Array(Int32))
    @costs : Array(Array(Int32))
    @features : Array(Array(String))
    @total_features : Int32
    @character_definition : CharacterDefinitions

    def initialize(@character_definition, @entries, @costs, @features, @total_features)
    end

    # 重载构造函数，提供默认的 total_features
    def initialize(@character_definition, @entries, @costs, @features)
      @total_features = @features.size
    end

    def lookup_word_ids(category_id : Int32) : Array(Int32)
      # Returns an array of word ids
      @entries[category_id]
    end

    def get_left_id(word_id : Int32) : Int32
      @costs[word_id][0]
    end

    def get_right_id(word_id : Int32) : Int32
      @costs[word_id][1]
    end

    def get_word_cost(word_id : Int32) : Int32
      @costs[word_id][2]
    end

    def get_all_features(word_id : Int32) : String
      get_all_features_array(word_id).join(@@feature_separator)
    end

    def get_all_features_array(word_id : Int32) : Array(String)
      if @total_features == @features.size
        return @features[word_id]
      end

      all_features = Array(String).new(@total_features)
      basic_features = @features[word_id]

      # 复制基本特征
      basic_features.each do |feature|
        all_features << feature
      end

      # 用默认值填充剩余特征
      (basic_features.size...@total_features).each do |i|
        all_features << @@default_feature
      end

      all_features
    end

    def get_feature(word_id : Int32, *fields : Int32) : String
      all_features = get_all_features_array(word_id)
      features = Array(String).new(fields.size)

      fields.each do |field_number|
        features << all_features[field_number]
      end

      features.join(@@feature_separator)
    end

    def get_character_definition : CharacterDefinitions
      @character_definition
    end

    def self.new_instance(resolver : ResourceResolver, character_definitions : CharacterDefinitions, total_features : Int32) : UnknownDictionary
      io = resolver.resolve(unknown_dictionary_filename)

      begin
        costs = IntegerArrayIO.read_array_2d(io)
        references = IntegerArrayIO.read_array_2d(io)
        features = StringArrayIO.read_array_2d(io)

        UnknownDictionary.new(character_definitions, references, costs, features, total_features)
      ensure
        io.close
      end
    end
  end
end
