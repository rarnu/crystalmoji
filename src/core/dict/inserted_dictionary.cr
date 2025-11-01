require "./dictionary"

module CrystalMoji::Dict
  class InsertedDictionary
    include Dictionary

    @@default_feature = "*"
    @@feature_separator = ","

    @features_array : Array(String)
    @features_string : String

    def initialize(features : Int32)
      @features_array = Array.new(features, @@default_feature)
      @features_string = @features_array.join(@@feature_separator)
    end

    def get_left_id(word_id : Int32) : Int32
      0
    end

    def get_right_id(word_id : Int32) : Int32
      0
    end

    def get_word_cost(word_id : Int32) : Int32
      0
    end

    def get_all_features(word_id : Int32) : String
      @features_string
    end

    def get_all_features_array(word_id : Int32) : Array(String)
      @features_array
    end

    def get_feature(word_id : Int32, *fields : Int32) : String
      features = Array(String).new(fields.size, @@default_feature)
      features.join(@@feature_separator)
    end

    # 如果需要支持数组参数的重载版本
    def get_feature_with_array(word_id : Int32, fields : Array(Int32)) : String
      features = Array(String).new(fields.size, @@default_feature)
      features.join(@@feature_separator)
    end
  end
end
