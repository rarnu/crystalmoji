module CrystalMoji::Buffer
  class FeatureInfoMap
    @feature_map : Hash(String, Int32) = Hash(String, Int32).new
    @max_value : Int32 = 0

    def map_features(features : Array(String)) : Array(Int32)
      pos_feature_ids : Array(Int32) = [] of Int32
      features.each do |feature|
        if @feature_map.has_key?(feature)
          pos_feature_ids.push(@feature_map[feature])
        else
          @feature_map[feature] = @max_value
          pos_feature_ids.push(@max_value)
          @max_value += 1
        end
      end
      pos_feature_ids
    end

    def invert : Hash(Int32, String)
      features = Hash(Int32, String).new
      @feature_map.each do |key, value|
        features[value] = key
      end
      features
    end

    def get_entry_count : Int32
      @max_value
    end

    def to_s(io : IO) : Nil
      io << "FeatureInfoMap{featureMap=#{@feature_map}, maxValue=#{@max_value}}"
    end
  end
end
