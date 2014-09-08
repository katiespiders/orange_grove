class OrangeGrove
  def initialize(num_new_trees)
    @trees = []
    num_new_trees.times do
      @trees << OrangeTree.new
    end
  end

  def plant_tree
    @trees << OrangeTree.new
  end

  # is this bad practice?
  def one_year_passes
    @trees.each do |tree|
      tree.one_year_passes
    end
  end

  def count_all_oranges
    total_oranges = 0
    @trees.each do |tree|
      total_oranges += tree.count_oranges
    end
  end


  class OrangeTree
    attr_accessor :height, :age, :age_category

    def initialize(height=0, age=0, orange_count=0)
      @height, @age, @orange_count = height, age, orange_count

      to_young_tree = rand(3..6)
      to_mature_tree = rand((to_young_tree + 3)..(to_young_tree + 6)) # range 6 to 12
      to_old_tree = rand((to_mature_tree + 10)..(to_mature_tree + 30)) # range 16 to 42
      to_death = rand((to_old_tree + 5)..(to_old_tree + 15)) # range 21 to 57

      @age_category_ranges = {
        sapling: (0...to_young_tree),
        young: (to_young_tree...to_mature_tree),
        mature: (to_mature_tree...to_old_tree),
        old: (to_old_tree...to_death),
        dead: (to_death..to_death)
      }

      @age_category = get_age_category

      puts "Created a #{@age}-year-old #{@age_category} tree, #{@height} feet tall with #{@orange_count} oranges."

    end

    def get_age_category
      @age_category_ranges.each do |category, age_range|
        if age_range.include? @age
          return category
        end
      end
    end

    def grow
      case @age_category
      when :sapling
        return @height + rand(3..7), 0
      when :young
        return @height + rand(1..3), rand(10..20)
      when :mature
        return @height + rand(0..2), rand(20..100)
      when :old
        return @height, rand(10..20)
      when :dead
        return @height, 0
      end
    end

    def one_year_passes
      if not @age_category == :dead
        @age += 1
        @age_category = get_age_category
        @height, @orange_count = grow
      end
      description = "Tree is a #{@age}-year-old #{@age_category} tree, #{@height} feet tall with #{@orange_count} oranges."
      puts description
      return description
    end

    def count_oranges
      return @orange_count
    end

    def pick_orange
      if @orange_count > 0
        @orange_count -= 1
        case @age_category
        when :young, :old
          return "That orange was just ok. The tree is too #{@age_category}."
        when :mature
          return "Om nom nom!"
        else
          return "How did you get into this block? #{@age_category.to_s.capitalize} trees don't bear fruit."
        end

      else
        return "No oranges for you :("
      end
    end

  end
end
