Hasu.load "tool.rb"

class Player
  SPEED = 0.1
  TURN_SPEED = 0.3
  REACH = 5
  WIDTH = 0.4
  SIGHT = 50

  attr_reader :y_angle, :x_angle, :x, :y, :z, :tool

  def initialize
    @x = 0
    @y = 20
    @z = 0
    @y_angle = 0
    @x_angle = 0
    @velocity = 0.0

    @lat_bob = 0
    @vert_bob = 0

    @tool = Hand.new
  end

  def view_x
    x + Gosu.offset_y(@y_angle, 1) * Math.sin(@lat_bob) * 0.1
  end

  def view_y
    y + Math.sin(@vert_bob)*0.08
  end

  def view_z
    z + Gosu.offset_x(@y_angle, 1) * -Math.sin(@lat_bob) * 0.1
  end

  def bob!
    @lat_bob += 0.1
    @vert_bob += 0.2

    @tool.bob!
  end

  def x1; @x-WIDTH; end
  def x2; @x+WIDTH; end
  def y1; @y-1.5; end
  def y2; @y+0.5; end
  def z1; @z-WIDTH; end
  def z2; @z+WIDTH; end

  def move!(directions)
    forward = 0
    forward += 1  if directions.fetch(:forward)
    forward -= 1  if directions.fetch(:backward)

    right = 0
    right   += 1  if directions.fetch(:right)
    right   -= 1  if directions.fetch(:left)

    total = forward.abs + right.abs
    return  if total == 0

    dx = Gosu.offset_x(@y_angle, SPEED/Math.sqrt(total)) * forward -
      Gosu.offset_y(@y_angle, SPEED/Math.sqrt(total)) * right

    dz = Gosu.offset_y(@y_angle, SPEED/Math.sqrt(total)) * forward +
      Gosu.offset_x(@y_angle, SPEED/Math.sqrt(total)) * right

    _translate!(dx, dz)
  end

  def _translate!(dx, dz)
    @x += dx
    @z += dz
    bob!

    resolve_horizontal_collision
    resolve_horizontal_collision
  end

  # Corrects the Player's position after horizontal collision
  # Based off of http://go.colorize.net/xna/2d_collision_response_xna/
  def resolve_horizontal_collision
    unless colliding_blocks.empty?
      x_resolutions = colliding_blocks.map do |block|
        pos = block.x2 - x1
        neg = block.x1 - x2

        pos < neg.abs ? pos : neg
      end

      z_resolutions = colliding_blocks.map do |block|
        pos = block.z2 - z1
        neg = block.z1 - z2

        pos < neg.abs ? pos : neg
      end

      pos_x, neg_x = x_resolutions.partition{|x| x > 0 }
      pos_z, neg_z = z_resolutions.partition{|z| z > 0 }

      dx = if pos_x.size > neg_x.size
        pos_x.min
      elsif pos_x.size < neg_x.size
        neg_x.max
      elsif pos_z.size == neg_z.size
        x_resolutions.min_by(&:abs)
      else
        1.0/0
      end

      dz = if pos_z.size > neg_z.size
        pos_z.min
      elsif pos_z.size < neg_z.size
        neg_z.max
      elsif pos_x.size == neg_x.size
        z_resolutions.min_by(&:abs)
      else
        1.0/0
      end

      if dx.abs < dz.abs
        @x += dx
      else
        @z += dz
      end
    end
  end

  def fall!
    gravity!

    @y += @velocity

    unless colliding_blocks.empty?
      dy = if @velocity > 0
             colliding_blocks.map(&:y1).min - y2
           else
             colliding_blocks.map(&:y2).max - y1
           end

      @y += dy
      @velocity = 0
    end
  end

  def jump!
    if @velocity == 0
      @velocity = 0.19
    end
  end

  def gravity!
    @velocity -= 0.006
  end

  def right!
    @y_angle += TURN_SPEED
  end

  def left!
    @y_angle -= TURN_SPEED
  end

  def turn!(d)
    @y_angle += d * TURN_SPEED
  end

  def look_up!(d)
    @x_angle -= d * TURN_SPEED
    @x_angle = [[90, @x_angle].min, -90].max
  end

  def _reach_ray
    (0..REACH).step(0.05).map do |distance|
      horizontal = Math.cos(x_angle * Math::PI / 180) * distance
      vertical = Math.sin(x_angle * Math::PI / 180) * distance

      rx = x + Math.sin(y_angle * Math::PI / 180) * horizontal
      rz = z - Math.cos(y_angle * Math::PI / 180) * horizontal
      ry = y + vertical
      [rx.round,ry.round,rz.round]
    end
  end

  def targeted_block
    loc = _reach_ray.find do |x, y, z|
      Blocks.exists?(x, y, z)
    end
    loc && Blocks[*loc]
  end

  def targeted_empty_loc
    _reach_ray.each_cons(2).select do |current, nex|
      Blocks.exists?(*nex)
    end.map(&:first).first
  end

  def colliding_blocks
    x_min = x1.floor.to_i
    x_max = x2.ceil.to_i
    y_min = y1.floor.to_i
    y_max = y2.ceil.to_i
    z_min = z1.floor.to_i
    z_max = z2.ceil.to_i

    nearby_blocks = (x_min..x_max).flat_map do |x|
      (y_min..y_max).flat_map do |y|
        (z_min..z_max).flat_map do |z|
          Array(Blocks[x, y, z])
        end
      end
    end

    nearby_blocks.select{|b| colliding?(b) }
  end

  # AABB collision detection.
  # Based off of http://stackoverflow.com/questions/3631437/cube-on-cube-collision-detection-algorithm
  def colliding?(block)
    x2 > block.x1 &&
      x1 < block.x2 &&
      y2 > block.y1 &&
      y1 < block.y2 &&
      z2 > block.z1 &&
      z1 < block.z2
  end

  def dig!
    @tool.swing!
    if targeted_block && (!@last_dig || @last_dig + 6 <= $tick)
      @last_dig = $tick
      targeted_block.dig!
    end
  end
end
