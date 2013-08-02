Hasu.load "point.rb"

class Block
  attr_reader :loc

  def initialize(x, y, z, blocks)
    @loc = Point.new(x, y, z)
    @blocks = blocks
  end

  def x1; @x1 ||= loc.x-0.5 ; end
  def x2; @x2 ||= loc.x+0.5 ; end
  def y1; @y1 ||= loc.y-0.5 ; end
  def y2; @y2 ||= loc.y+0.5 ; end
  def z1; @z1 ||= loc.z-0.5 ; end
  def z2; @z2 ||= loc.z+0.5 ; end

  def faces_to_show
    return @faces  if @faces
    @faces = []
    @faces << LISTS.fetch(:right)  unless @blocks.has_key?(loc.right)
    @faces << LISTS.fetch(:left)   unless @blocks.has_key?(loc.left)
    @faces << LISTS.fetch(:top)    unless @blocks.has_key?(loc.up)
    @faces << LISTS.fetch(:bottom) unless @blocks.has_key?(loc.down)
    @faces << LISTS.fetch(:front)  unless @blocks.has_key?(loc.front)
    @faces << LISTS.fetch(:back)   unless @blocks.has_key?(loc.back)
    @faces
  end

  def flb; [x1, y1, z1]; end
  def flt; [x1, y2, z1]; end
  def frb; [x2, y1, z1]; end
  def frt; [x2, y2, z1]; end
  def blb; [x1, y1, z2]; end
  def blt; [x1, y2, z2]; end
  def brb; [x2, y1, z2]; end
  def brt; [x2, y2, z2]; end

  def top    ; frt+flt+blt+brt; end
  def front  ; flb+flt+frt+frb; end
  def back   ; brb+brt+blt+blb; end
  def bottom ; flb+frb+brb+blb; end
  def right  ; frb+frt+brt+brb; end
  def left   ; blb+blt+flt+flb; end

  def tex_top    ; [0, 1, 0, 0, 1, 0, 1, 1]; end
  def tex_side   ; [3, 1, 3, 0, 4, 0, 4, 1]; end
  def tex_bottom ; [2, 1, 2, 0, 3, 0, 3, 1]; end

  def top_color   ; [0.3, 0.6, 0.4, 1]; end
  def other_color ; [1,   1,   1,   1]; end

  def vertices
    @vertices ||= top + bottom + front + back + right + left
  end

  def tex_coords
    @tex_coords ||=
      (
      tex_top + tex_bottom + tex_side + tex_side + tex_side + tex_side
      ).map{ |c| c/16.0 }
  end

  def colors
    @colors ||= top_color*4 + other_color*5*4
  end

  def draw
  end

  def inspect
    "#<Block: {@loc}>"
  end
end
