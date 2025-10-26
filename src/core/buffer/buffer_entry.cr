module CrystalMoji::Buffer
  class BufferEntry
    property token_info : Array(Int16) = [] of Int16
    property features : Array(Int32) = [] of Int32
    property pos_info : Array(UInt8) = [] of UInt8

    property token_infos : Array(Int16)
    property feature_infos : Array(Int32)
    property pos_infos : Array(UInt8)

    def initialize(@token_infos : Array(Int16), @feature_infos : Array(Int32), @pos_infos : Array(UInt8))
    end
  end
end
