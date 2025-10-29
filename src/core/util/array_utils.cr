module ArrayExtension(T)
  def to_slice : Slice(T)
    Slice.new(@buffer, size)
  end

  def contains?(value : T) : Bool
    !index(value).nil?
  end

  def contains_all?(values : Array(T)) : Bool
    values.all? { |value| contains?(value) }
  end
end

class Array(T)
  include ArrayExtension(T)
end
