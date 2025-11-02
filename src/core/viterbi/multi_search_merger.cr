require "../util/queue_util"

module CrystalMoji::Viterbi
  class MultiSearchMerger
    @base_cost : Int32 = 0
    @suffix_cost_lower_bounds = [] of Int32
    @max_count : Int32
    @cost_slack : Int32

    def initialize(@max_count, @cost_slack)
    end

    def merge(results : Array(MultiSearchResult)) : MultiSearchResult
      if results.empty?
        return MultiSearchResult.new
      end

      @suffix_cost_lower_bounds = Array.new(results.size, 0)
      @suffix_cost_lower_bounds[results.size - 1] = results.last.get_cost(0)

      (results.size - 2).downto(0) do |i|
        @suffix_cost_lower_bounds[i] = results[i].get_cost(0) + @suffix_cost_lower_bounds[i + 1]
      end

      @base_cost = @suffix_cost_lower_bounds[0]

      ret = MultiSearchResult.new
      builders = [] of MergeBuilder

      results[0].size.times do |i|
        if get_cost_lower_bound(results[0].get_cost(i), 0) - @base_cost > @cost_slack || i == @max_count
          break
        end

        new_builder = MergeBuilder.new(results)
        new_builder.add(i)
        builders << new_builder
      end

      (1...results.size).each do |i|
        builders = merge_step(builders, results, i)
      end

      builders.each do |builder|
        ret.add(builder.build_list, builder.cost)
      end

      ret
    end

    private def merge_step(builders : Array(MergeBuilder), results : Array(MultiSearchResult), current_index : Int32) : Array(MergeBuilder)
      next_result = results[current_index]
      pair_heap = CrystalMoji::Util::PriorityQueue(MergePair).new
      ret = [] of MergeBuilder

      if builders.empty? || next_result.size == 0
        return ret
      end

      pair_heap.push(MergePair.new(0, 0, builders[0].cost + next_result.get_cost(0)))
      visited = Set(Int32).new

      while ret.size < @max_count && !pair_heap.empty?
        top = pair_heap.pop

        if get_cost_lower_bound(top.not_nil!.cost, current_index) - @base_cost > @cost_slack
          break
        end

        i = top.not_nil!.left_index
        j = top.not_nil!.right_index

        next_builder = MergeBuilder.new(results, builders[i].indices)
        next_builder.add(j)
        ret << next_builder

        if i + 1 < builders.size
          new_merge_pair = MergePair.new(i + 1, j, builders[i + 1].cost + next_result.get_cost(j))
          position_value = get_position_value(i + 1, j)
          unless visited.includes?(position_value)
            pair_heap.push(new_merge_pair)
            visited.add(position_value)
          end
        end

        if j + 1 < next_result.size
          new_merge_pair = MergePair.new(i, j + 1, builders[i].cost + next_result.get_cost(j + 1))
          position_value = get_position_value(i, j + 1)
          unless visited.includes?(position_value)
            pair_heap.push(new_merge_pair)
            visited.add(position_value)
          end
        end
      end

      ret
    end

    private def get_position_value(i : Int32, j : Int32) : Int32
      (@max_count + 1) * i + j
    end

    private def get_cost_lower_bound(current_cost : Int32, index : Int32) : Int32
      if index + 1 < @suffix_cost_lower_bounds.size
        current_cost + @suffix_cost_lower_bounds[index + 1]
      else
        current_cost
      end
    end

    class MergeBuilder
      include Comparable(MergeBuilder)

      property cost : Int32
      property indices : Array(Int32)
      property results : Array(MultiSearchResult)

      def initialize(@results)
        @cost = 0
        @indices = [] of Int32
      end

      def initialize(@results, indices : Array(Int32))
        @cost = 0
        @indices = indices.dup
        @indices.each do |index|
          @cost += @results[@indices.size - 1].get_cost(index)
        end
      end

      def build_list : Array(ViterbiNode)
        ret = [] of ViterbiNode
        @indices.each_with_index do |index, i|
          ret.concat(@results[i].get_tokenized_result(index))
        end
        ret
      end

      def add(index : Int32)
        @indices << index
        @cost += @results[@indices.size - 1].get_cost(index)
      end

      def <=>(other : MergeBuilder) : Int32
        @cost <=> other.cost
      end
    end

    private class MergePair
      include Comparable(MergePair)

      property left_index : Int32
      property right_index : Int32
      property cost : Int32

      def initialize(@left_index, @right_index, @cost)
      end

      def <=>(other : MergePair) : Int32
        @cost <=> other.cost
      end
    end
  end
end
