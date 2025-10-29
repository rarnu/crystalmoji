module ArrayExtension(T)
  def to_slice : Slice(T)
    Slice.new(@buffer, size)
  end
end

class Array(T)
  include ArrayExtension(T)
end
