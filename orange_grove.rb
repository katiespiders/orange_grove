require './orange_tree.rb'
require './grove_painter.rb'

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
end

def main

  trees = rand(1..16)
  percent_capacity = rand(1..50) / 100.0
  capacity = (trees / percent_capacity).round

  puts "#{trees} trees out of max #{capacity}"
  grove = OrangeGrove.new(trees, capacity)

  4.times do
    grove.years_pass(10)
    grove.trees[0].pick_oranges
    grove.plant_trees(rand(0..9))
  end

end

100.times {main}
