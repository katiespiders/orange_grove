
  class GrovePainter

    def initialize(grove)
      @grove = grove
      @soil_char = check_soil_quality
      @tree_states = check_tree_states
      draw
    end

    def check_soil_quality
      if @grove.soil_quality < 0.25
        @soil_char = "_"
      elsif @grove.soil_quality < 0.75
        @soil_char = "."
      else
        @soil_char = ","
      end
      return @soil_char
    end

    def check_tree_states
      @tree_states = []

      @grove.trees.each do |tree|
        case tree.age_category
        when :sapling
          tree_graphic = "_:_"
        when :young, :old
          tree_graphic = "_l_"
        when :mature
          tree_graphic = "<|>"
        when :dead
          tree_graphic = "_!_"
        else # this shouldn't happen
          tree_graphic = "???"
        end
        @tree_states << {
          count: tree.count_oranges.to_s.center(7),
          graphic: tree_graphic.center(7, @soil_char)
          }
      end
      return @tree_states
    end

    def draw
      if @grove.size <= 8
        rows = 1
        last_row_size = @grove.size
      elsif @grove.size % 8 ==0
        rows = @grove.size / 8
        last_row_size = 8
      else
        rows = @grove.size / 8 + 1
        last_row_size = @grove.size % 8
      end

      draw_border
      current_row = 0
      (rows - 1).times do
        draw_row(current_row)
        current_row += 1
      end

      draw_row(current_row, last_row_size)
    end

    def draw_border
      puts "-" * 56
      puts " " * 56
    end

    def draw_row(current_row, row_width=8)
      index = current_row * 8
      trees_this_row = @tree_states.values_at(index...index+row_width)
      counts_this_row = trees_this_row.collect { |tree| tree[:count] }
      graphics_this_row = trees_this_row.collect{ |tree| tree[:graphic] }

      row_counts_string = counts_this_row.join
      row_graphics_string = graphics_this_row.join

    puts row_counts_string
    puts row_graphics_string
    draw_border
    end

  end
