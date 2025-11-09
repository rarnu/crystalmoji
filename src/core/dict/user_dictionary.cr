require "./dictionary"
require "../util/dictionary_entry_line_parser"

module CrystalMoji::Dict
  class UserDictionary
    include Dictionary

    @@simple_userdict_fields : Int32 = 4
    @@word_cost_base : Int32 = -100000
    @@minimum_word_cost : Int32 = Int32::MIN // 2
    @@left_id : Int32 = 5
    @@right_id : Int32 = 5
    @@default_feature : String = "*"
    class_getter feature_separator : String = ","

    @entries : Array(UserDictionaryEntry)
    @reading_feature : Int32
    @part_of_speech_feature : Int32
    @total_features : Int32
    @surfaces : Hash(String, Array(Int32))

    def initialize(input : IO, @total_features, @reading_feature, @part_of_speech_feature : Int32)
      @entries = [] of UserDictionaryEntry
      @surfaces = {} of String => Array(Int32)
      read(input)
    end

    def find_user_dictionary_matches(text : String) : Array(UserDictionaryMatch)
      match_infos = [] of UserDictionaryMatch
      start_index = 0

      while start_index < text.size
        match_length = 0
        end_index = 1

        while current_input_contains_potential_match(text, start_index, end_index)
          match_candidate = text[start_index, end_index]

          if @surfaces.has_key?(match_candidate)
            match_length = end_index
          end

          end_index += 1
        end

        if match_length > 0
          match = text[start_index, match_length]
          details = @surfaces[match]

          if details
            match_infos.concat(make_match_details(start_index, details))
          end
        end

        start_index += 1
      end

      match_infos
    end

    private def current_input_contains_potential_match(text : String, start_index : Int32, end_index : Int32) : Bool
      return false if start_index + end_index > text.size

      substring = text[start_index, end_index]
      @surfaces.keys.any? { |key| key.starts_with?(substring) }
    end

    def get_left_id(word_id : Int32) : Int32
      entry = @entries[word_id]
      entry.get_left_id
    end

    def get_right_id(word_id : Int32) : Int32
      entry = @entries[word_id]
      entry.get_right_id
    end

    def get_word_cost(word_id : Int32) : Int32
      entry = @entries[word_id]
      entry.get_word_cost
    end

    def get_all_features(word_id : Int32) : String
      entry = @entries[word_id]
      entry.get_all_features
    end

    def get_all_features_array(word_id : Int32) : Array(String)
      entry = @entries[word_id]
      entry.get_all_features_array
    end

    def get_feature(word_id : Int32, *fields : Int32) : String
      entry = @entries[word_id]
      entry.get_feature(fields.to_a)
    end

    private def make_match_details(match_start_index : Int32, details : Array(Int32)) : Array(UserDictionaryMatch)
      match_details = [] of UserDictionaryMatch

      word_id = details[0]
      start_index = 0

      (1...details.size).each do |i|
        match_length = details[i]

        match_details << UserDictionaryMatch.new(
          word_id, match_start_index + start_index, match_length
        )

        start_index += match_length
        word_id += 1
      end

      match_details
    end

    private def read(input : IO) : Nil
      input.each_line do |line|
        # Remove comments and trim leading and trailing whitespace
        line = line.gsub(/#.*$/, "").strip

        # Skip empty lines or comment lines
        next if line.empty?

        add_entry(line)
      end
    end

    def add_entry(entry : String) : Nil
      values = CrystalMoji::Util::DictionaryEntryLineParser.parse_line(entry)

      if values.size == @@simple_userdict_fields
        add_simple_entry(values)
      elsif values.size == @total_features + 4 # 4 = surface, left id, right id, word cost
        add_full_entry(values)
      else
        raise "Illegal user dictionary entry #{entry}"
      end
    end

    private def add_full_entry(values : Array(String)) : Nil
      surface = values[0]
      costs = [
        values[1].to_i,
        values[2].to_i,
        values[3].to_i,
      ]

      features = values[4..-1]

      entry = UserDictionaryEntry.new(
        surface, costs, features
      )

      word_id_and_lengths = [@entries.size, surface.size]
      @entries << entry
      @surfaces[surface] = word_id_and_lengths
    end

    private def add_simple_entry(values : Array(String)) : Nil
      surface = values[0]
      segmentation_value = values[1]
      readings_value = values[2]
      part_of_speech = values[3]

      segmentation = nil
      readings = nil

      if custom_segmentation?(surface, segmentation_value)
        segmentation = split(segmentation_value)
        readings = split(readings_value)
      else
        segmentation = [segmentation_value]
        readings = [readings_value]
      end

      if segmentation.size != readings.size
        raise "User dictionary entry not properly formatted: #{values}"
      end

      # { wordId, 1st token length, 2nd token length, ... , nth token length
      word_id_and_lengths = Array(Int32).new(segmentation.size + 1)
      word_id = @entries.size
      word_id_and_lengths << word_id

      segmentation.each_with_index do |segment, i|
        word_id_and_lengths << segment.size

        features = make_simple_features(part_of_speech, readings[i])
        costs = make_costs(surface.size)

        entry = UserDictionaryEntry.new(
          segment, costs, features
        )

        @entries << entry
      end

      @surfaces[surface] = word_id_and_lengths
    end

    private def make_costs(length : Int32) : Array(Int32)
      word_cost = @@word_cost_base * length
      if word_cost < @@minimum_word_cost
        word_cost = @@minimum_word_cost
      end

      [@@left_id, @@right_id, word_cost]
    end

    private def make_simple_features(part_of_speech : String, reading : String) : Array(String)
      features = empty_feature_array
      features[@part_of_speech_feature] = part_of_speech
      features[@reading_feature] = reading
      features
    end

    private def empty_feature_array : Array(String)
      Array.new(@total_features, @@default_feature)
    end

    private def custom_segmentation?(surface : String, segmentation : String) : Bool
      surface != segmentation
    end

    private def split(input : String) : Array(String)
      input.split
    end
  end

  class UserDictionaryMatch
    property word_id : Int32
    property match_start_index : Int32
    property match_length : Int32

    def initialize(@word_id, @match_start_index, @match_length)
    end

    def to_s : String
      "UserDictionaryMatch{wordId=#{@word_id}, matchStartIndex=#{@match_start_index}, matchLength=#{@match_length}}"
    end
  end

  class UserDictionaryEntry
    property surface : String
    property costs : Array(Int32)
    property features : Array(String)

    def initialize(@surface, @costs, @features)
    end

    def get_left_id : Int32
      @costs[0]
    end

    def get_right_id : Int32
      @costs[1]
    end

    def get_word_cost : Int32
      @costs[2]
    end

    def get_all_features_array : Array(String)
      @features
    end

    def get_all_features : String
      @features.join(UserDictionary.feature_separator)
    end

    def get_feature(fields : Array(Int32)) : String
      f = Array(String).new(fields.size)

      fields.each do |field_number|
        f << @features[field_number]
      end

      f.join(UserDictionary.feature_separator)
    end

    def to_s : String
      builder = "#{@surface}#{UserDictionary.feature_separator}#{@costs[0]}#{UserDictionary.feature_separator}#{@costs[1]}#{UserDictionary.feature_separator}#{@costs[2]}#{UserDictionary.feature_separator}"
      builder + @features.join(UserDictionary.feature_separator)
    end
  end


end
