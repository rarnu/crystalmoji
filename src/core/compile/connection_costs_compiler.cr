require "./compiler"

module CrystalMoji::Compile
  class ConnectionCostsCompiler
    include Compiler

    @@short_bytes : Int32 = 2

    @output : IO
    @cardinality : Int32 = 0
    @buffer_size : Int32 = 0
    @costs = [] of Int16

    def initialize(@output : IO)
    end

    def read_costs(input : IO)
      line_reader = input

      # Read first line with cardinalities
      line = line_reader.gets
      return unless line

      cardinalities = line.split(/\s+/)

      raise "Expected 2 cardinalities, got #{cardinalities.size}" unless cardinalities.size == 2

      forward_size = cardinalities[0].to_i
      backward_size = cardinalities[1].to_i

      raise "Forward and backward sizes must be equal" unless forward_size == backward_size
      raise "Forward size must be positive" unless forward_size > 0
      raise "Backward size must be positive" unless backward_size > 0

      @cardinality = backward_size
      @buffer_size = forward_size * backward_size
      @costs = Array(Int16).new(@buffer_size, 0)

      # Read cost entries
      while (line = line_reader.gets)
        fields = line.split(/\s+/)

        next if fields.empty?
        raise "Expected 3 fields, got #{fields.size}" unless fields.size == 3

        forward_id = fields[0].to_i16
        backward_id = fields[1].to_i16
        cost = fields[2].to_i16

        put_cost(forward_id, backward_id, cost)
      end
    end

    def put_cost(forward_id : Int16, backward_id : Int16, cost : Int16)
      index = backward_id + forward_id * @cardinality
      if index >= 0 && index < @costs.size
        @costs[index] = cost
      else
        raise "Index out of bounds: #{index} (costs size: #{@costs.size})"
      end
    end

    def compile
      # Use buffered output
      buffered_output = @output

      # Write cardinality and buffer size in bytes
      buffered_output.write_bytes(@cardinality, IO::ByteFormat::BigEndian)
      buffered_output.write_bytes(@buffer_size * @@short_bytes, IO::ByteFormat::BigEndian)

      # Write all costs as big-endian Int16 values
      @costs.each do |cost|
        buffered_output.write_bytes(cost, IO::ByteFormat::BigEndian)
      end

      buffered_output.flush
    end

    def get_cardinality : Int32
      @cardinality
    end

    def get_costs : Array(Int16)
      @costs
    end
  end
end
