module CrystalMoji::Dict

  module Dictionary

    abstract def get_left_id(word_id : Int32) : Int32

    abstract def get_right_id(word_id : Int32) : Int32

    abstract def get_word_cost(word_id : Int32) : Int32

    abstract def get_all_features(word_id : Int32) : String

    abstract def get_all_features_array(word_id : Int32) : Array(String)

    abstract def get_feature(word_id : Int32, *fields : Int32) : String

  end

end



