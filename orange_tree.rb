class OrangeGrove

  attr_accessor :trees

  def initialize(num_new_trees, capacity=100)
    @trees = []
    @capacity = capacity
    @soil_quality = 100

    set_soil_quality(num_new_trees)
    num_new_trees.times do
      @trees << OrangeTree.new(0, 0, 0, @soil_quality)
    end
  end

  def plant_trees(num_new_trees)
    soil_damage = num_new_trees
    if @soil_quality - soil_damage <= 0
      puts "The grove is too crowded. You have room for only #{@capacity - @trees.length} more trees."
    else
      set_soil_quality(num_new_trees)
      num_new_trees.times do
        @trees << OrangeTree.new(0, 0, 0, @soil_quality)
      end
    end
  end

  def set_soil_quality(num_new_trees)
    @soil_quality -= num_new_trees
  end

  def years_pass(num_years)
    num_years.times do
      one_year_passes
    end
  end

  # is this bad practice?
  def one_year_passes
    @trees.each do |tree|
      tree.one_year_passes(@soil_quality)
    end
  end

  def count_all_oranges
    total_oranges = 0
    @trees.each do |tree|
      total_oranges += tree.count_oranges
    end
    return total_oranges
  end


  class OrangeTree
    attr_accessor :height, :age, :age_category, :health, :orange_county

    def initialize(height=0, age=0, orange_count=0, soil_quality=100)

      @height, @age, @orange_count = height, age, orange_count
      @health = adjust_health(soil_quality)
      @age_category_ranges = calc_age_cutoffs

      death_cutoff = 0.25 * (100 - soil_quality)

      if rand(0..100) < death_cutoff
        @age_category = :dead
      else
        @age_category = get_age_category
      end

      if @age > 0
        puts "Transplanted a #{@age}-year-old #{@age_category} tree, #{@height} feet tall with #{@orange_count} oranges."
      else
        puts "Planted a new orange tree, which will start producing fruit in #{@to_young_tree.ceil} years."
      end
    end

    def calc_age_cutoffs
      # there has to be a better way to do this
      @to_young_tree = (rand(3..6) / @health) # lower health = slower maturity
      to_mature_tree = rand((@to_young_tree + 3)..(@to_young_tree + 6)) / @health # lower health = slower maturity
      to_old_tree = rand((to_mature_tree + 10)..(to_mature_tree + 30)) * @health # lower health = faster aging after maturity
      to_death = rand((to_old_tree + 5)..(to_old_tree + 15)) * @health # lower health = faster death

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
      grove.trees << OrangeTree.new
    end

    def adjust_health(soil_quality)
      @health = soil_quality.to_f / 100
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

    def one_year_passes(soil_quality)
      if not @age_category == :dead
        @age += 1
        @age_category = get_age_category
        @height, @orange_count = grow(soil_quality)
      end
      description = "Tree is a #{@age}-year-old #{@age_category} tree, #{@height} feet tall with #{@orange_count} oranges."
      puts description
      return description
    end

    def count_oranges
      return @orange_count
    end

    def pick_oranges(num_oranges = 1)
      if @orange_count == 0
        return "No oranges for you :("
      elsif num_oranges > @orange_count
        puts eat_oranges
        puts "You ate #{@orange_count} oranges. They're all gone now."
        @orange_count = 0
      else
        puts eat_oranges
        @orange_count -= num_oranges
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
end
