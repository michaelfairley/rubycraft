Hasu.load "blocks.rb"
Hasu.load "point.rb"
Hasu.load "face.rb"

class Block
  attr_reader :loc

  def initialize(x, y, z)
    @loc = Point.new(x, y, z)
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
    @faces << right  unless Blocks.exists?(loc.right)
    @faces << left   unless Blocks.exists?(loc.left)
    @faces << top    unless Blocks.exists?(loc.up)
    @faces << bottom unless Blocks.exists?(loc.down)
    @faces << front  unless Blocks.exists?(loc.front)
    @faces << back   unless Blocks.exists?(loc.back)
    @faces
  end

  def dirty!
    @faces = nil
  end

  def flb; [x1, y1, z1]; end
  def flt; [x1, y2, z1]; end
  def frb; [x2, y1, z1]; end
  def frt; [x2, y2, z1]; end
  def blb; [x1, y1, z2]; end
  def blt; [x1, y2, z2]; end
  def brb; [x2, y1, z2]; end
  def brt; [x2, y2, z2]; end

  def top    ;    GrassFace.new(frt+flt+blt+brt); end
  def front  ; DirtSideFace.new(flb+flt+frt+frb); end
  def back   ; DirtSideFace.new(brb+brt+blt+blb); end
  def bottom ;     DirtFace.new(flb+frb+brb+blb); end
  def right  ; DirtSideFace.new(frb+frt+brt+brb); end
  def left   ; DirtSideFace.new(blb+blt+flt+flb); end

  def vertices
    faces_to_show.flat_map(&:vertices)
  end

  def tex_coords
    faces_to_show.flat_map(&:tex_coords)
  end

  def colors
    faces_to_show.flat_map(&:colors)
  end

  def inspect
    "#<Block: {@loc}>"
  end
end
