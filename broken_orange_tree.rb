class OrangeGrove

  attr_accessor :trees, :soil_quality

  def initialize(n, capacity=100)
    @trees = []
    @capacity = capacity
    @soil_quality = 1

    puts "Initial planting:"
    plant_trees(n)
  end

  def to_s
    return "The orange grove has #{size} trees out of a maximum of #{@capacity}, with soil quality #{@soil_quality * 100}%."
  end

  def size
    return @trees.length
  end

  def plant_trees(n=1)
    soil_damage = n.to_f / @capacity

    if size == @capacity
      n = 0
      puts "No new trees planted (grove is at capacity):"
    elsif size + n >= @capacity
      n = @capacity - size
      @soil_quality = 0
      puts "After planting #{n} new trees (grove is now at capacity):"
    else
      @soil_quality -= soil_damage
      puts "After planting #{n} new trees:"
    end

    n.times do
      @trees << OrangeTree.new(0, 0, 0, @soil_quality)
    end

    GrovePainter.new(self)
  end

  def years_pass(n=1)
    n.times do
      @trees.each do |tree|
        tree.one_year_passes(@soil_quality)
      end
    end
    puts "After #{n} years"
    GrovePainter.new(self)
  end

  def count_all_oranges
    total_oranges = 0
    @trees.each do |tree|
      total_oranges += tree.count_oranges
    end
    return total_oranges
  end


  class OrangeTree
    attr_accessor :height, :age, :age_category, :health, :orange_count

    def initialize(height=0, age=0, orange_count=0, soil_quality=1, show_debug=false)

      @height, @age, @orange_count = height, age, orange_count
      @health = adjust_health(soil_quality)
      @age_category_ranges = calc_age_cutoffs

      death_cutoff = 0.25 * (1 - soil_quality)

      if rand < death_cutoff
        @age_category = :dead
      else
        @age_category = get_age_category
      end

      if show_debug
        if @age > 0
          puts "Transplanted a #{@age}-year-old #{@age_category} tree, #{display_height} tall with #{@orange_count} oranges."
        else
          if @age_category != :dead
            puts "Planted a new orange tree, which will start producing fruit in #{@to_young_tree.ceil} years."
          else
            puts "Planted a new orange tree, but the soil quality is too poor for it to grow."
          end
        end
      end
    end

    def to_s
      return "This is a #{@age}-year-old #{@age_category} tree, #{display_height} tall with #{@orange_count} oranges."
    end

    def calc_age_cutoffs

      @to_young_tree = (rand(1..3) / @health).ceil # lower health = slower maturity
      to_mature_tree = (rand(5..10) / @health).ceil + @to_young_tree
      to_old_tree = (rand(20..30) * @health).ceil + to_mature_tree # lower health = faster decline
      to_death = (rand(5..10) * @health).ceil + to_old_tree

      @age_category_ranges = {
        sapling: (0...@to_young_tree),
        young: (@to_young_tree...to_mature_tree),
        mature: (to_mature_tree...to_old_tree),
        old: (to_old_tree...to_death),
        dead: (to_death..to_death)
      }
    end

    def get_age_category
      @age_category_ranges.each do |category, age_range|
        if age_range.include? @age
          return category
        end
      end
    end

    def self.plant_on(grove)
      grove.plant_trees(1)
    end

    def adjust_health(soil_quality)
      damage = 1.0 - soil_quality
      @health = 1.0 - 0.5 * damage
    end

    def grow(soil_quality)
      adjust_health(soil_quality)
      case @age_category
        when :sapling
          return @height + @health * rand(3..7), 0
        when :young
          return @height + @health * rand(1..3), (@health * rand(10..20)).to_i
        when :mature
          return @height + @health * rand(0..2), (@health * rand(20..100)).to_i
        when :old
          return @height, (@health * rand(10..20)).to_i
        when :dead
          return @height, 0
      end
    end

    def display_height
      inches = ((@height % 1) * 12).round
      feet = @height.floor
      return "#{feet}\' #{inches}\""
    end

    def one_year_passes(soil_quality)
      if not @age_category == :dead
        @age += 1
        @age_category = get_age_category
        @height, @orange_count = grow(soil_quality)
      end
    end

    def count_oranges
      return @orange_count
    end

    def pick_oranges(n=1)
      if @orange_count == 0
        puts "No oranges for you :("
      elsif n > @orange_count
        puts eat_oranges
        puts "You ate #{@orange_count} oranges. They're all gone now."
        @orange_count = 0
      else
        puts eat_oranges
        @orange_count -= n
        puts "You have #{@orange_count} oranges left."
      end
    end

    def eat_oranges
      case @age_category
        when :young, :old
          return "Those oranges were just ok. The tree is too #{@age_category}."
        when :mature
          return "Om nom nom!"
        else
          return "How did you get into this block? #{@age_category.to_s.capitalize} trees don't bear fruit."
      end
    end
  end

  class GrovePainter
    attr_accessor :soil_char, :tree_states

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
      else
        rows = @grove.size / 8 + 1
        last_row_size = @grove.size % 8
          if last_row_size == 0
            last_row_size = 8
          end
      end

      draw_border
      current_row = 0
      (rows - 1).times do
        draw_row(current_row)
        current_row += 1
      end

      draw_row(current_row, last_row_size)
      puts "\n\n"
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
end

def main

  trees = rand(4..8)
  percent_capacity = rand(1..50) / 100.0
  capacity = (trees / percent_capacity).round

  puts "#{trees} trees out of max #{capacity}"
  grove = OrangeGrove.new(trees, capacity)

  1.times do
    grove.trees[0].pick_oranges
    grove.years_pass(25)
    grove.plant_trees(2)
    puts "#{grove.trees.count} trees"
  end

end

10.times {main}
