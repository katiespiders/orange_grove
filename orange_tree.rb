  class OrangeTree
    attr_accessor :age_category

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
