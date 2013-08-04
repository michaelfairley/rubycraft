class Point
  attr_reader :x, :y, :z, :hash

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
    @hash = self.class.hash ^ [x, y, z].hash
  end

  def +(other)
    self.class.new(x + other.x, y + other.y, z + other.z)
  end

  def up
    @up ||= self + Vector.new(0, 1, 0)
  end

  def down
    @down ||= self + Vector.new(0, -1, 0)
  end

  def back
    @back ||= self + Vector.new(0, 0, 1)
  end

  def front
    @front ||= self + Vector.new(0, 0, -1)
  end

  def left
    @left ||= self + Vector.new(-1, 0, 0)
  end

  def right
    @right ||= self + Vector.new(1, 0, 0)
  end

  def sides
    [@up, @down, @left, @right, @front, @back]
  end

  def eql?(other)
    x == other.x && y == other.y && z == other.z
  end

  def ==(other)
    eql?(other)
  end
end

Vector = Point
