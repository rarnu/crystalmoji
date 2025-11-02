module CrystalMoji::Buffer
  class BufferEntry
    property token_info : Array(Int16) = [] of Int16
    property features : Array(Int32) = [] of Int32
    property pos_info : Array(UInt8) = [] of UInt8

    property token_infos : Array(Int16)? = nil
    property feature_infos : Array(Int32)? = nil
    property pos_infos : Array(UInt8)? = nil

    def initialize(@token_infos : Array(Int16)? = nil, @feature_infos : Array(Int32)? = nil, @pos_infos : Array(UInt8)? = nil)
    end
  end
end
