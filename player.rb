class Player
  SPEED = 0.1
  TURN_SPEED = 0.3
  REACH = 4
  WIDTH = 0.4

  attr_reader :x, :y, :z, :y_angle, :x_angle

  def initialize(blocks)
    @x = 0
    @y = 1
    @z = 0
    @y_angle = 0
    @x_angle = 0
    @blocks = blocks
    @velocity = 0.0
  end

  def x1; @x-WIDTH; end
  def x2; @x+WIDTH; end
  def y1; @y-1.5; end
  def y2; @y+0.5; end
  def z1; @z-WIDTH; end
  def z2; @z+WIDTH; end

  def _move!(dx, dz)
    @x += dx
    @z += dz

    colliding = @blocks.values.select{|b| colliding?(b) }

    unless colliding.empty?
      target_x = if dx > 0
                   colliding.map(&:x1).min - WIDTH
                 else
                   colliding.map(&:x2).max + WIDTH
                 end
      target_z = if dz > 0
                   colliding.map(&:z1).min - WIDTH
                 else
                   colliding.map(&:z2).max + WIDTH
                 end

      if (target_x - x).abs < (target_z - z).abs
        @x = target_x
      else
        @z = target_z
      end
    end
  end

  def fall!
    @y += @velocity

    colliding = @blocks.values.select{|b| colliding?(b) }

    unless colliding.empty?
      target_y = if @velocity > 0
                   colliding.map(&:y1).min - 0.5
                 else
                   colliding.map(&:y2).max + 1.5
                 end

      @y = target_y
      @velocity = 0
    end
  end

  def jump!
    if @velocity == 0
      @velocity = 0.19
    end
  end

  def gravity!
    @velocity -= 0.0077
  end

  def forward!
    _move!(Gosu.offset_x(@y_angle, SPEED), Gosu.offset_y(@y_angle, SPEED))
  end

  def backward!
    _move!(-Gosu.offset_x(@y_angle, SPEED), -Gosu.offset_y(@y_angle, SPEED))
  end

  def sright!
    _move!(-Gosu.offset_y(@y_angle, SPEED), Gosu.offset_x(@y_angle, SPEED))
  end

  def sleft!
    _move!(Gosu.offset_y(@y_angle, SPEED), -Gosu.offset_x(@y_angle, SPEED))
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

  def colliding?(block)
    x2 > block.x1 &&
      x1 < block.x2 &&
      y2 > block.y1 &&
      y1 < block.y2 &&
      z2 > block.z1 &&
      z1 < block.z2
  end

  def targeted_block
    (0..REACH).step(0.05).map do |distance|
      horizontal = Math.cos(x_angle * Math::PI / 180) * distance
      vertical = Math.sin(x_angle * Math::PI / 180) * distance

      x = @x + Math.sin(y_angle * Math::PI / 180) * horizontal
      z = @z - Math.cos(y_angle * Math::PI / 180) * horizontal
      y = @y + vertical
      [x,y,z]
    end.map do |x, y, z|
      @blocks[[x.round,y.round,z.round]]
    end.compact.first
  end
end
