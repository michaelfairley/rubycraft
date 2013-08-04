Hasu.load "blocks.rb"
Hasu.load "point.rb"
Hasu.load "face.rb"

class Block
  attr_reader :loc

  def initialize(loc)
    @loc = loc
    reset_strength!
  end

  def reset_strength!
    Blocks.damage_block = nil
    @strength = starting_strength
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

  def top    ;    top_face.new(frt+flt+blt+brt); end
  def front  ;  front_face.new(flb+flt+frt+frb); end
  def back   ;   back_face.new(brb+brt+blt+blb); end
  def bottom ; bottom_face.new(flb+frb+brb+blb); end
  def right  ;  right_face.new(frb+frt+brt+brb); end
  def left   ;   left_face.new(blb+blt+flt+flb); end

  def vertices
    faces_to_show.flat_map(&:vertices)
  end

  def tex_coords
    faces_to_show.flat_map(&:tex_coords)
  end

  def colors
    faces_to_show.flat_map(&:colors)
  end

  def dig!
    Blocks.damage_block = self
    @strength -= 1
    if @strength <= 0
      Blocks.remove!(self)
    end
  end

  def damage_faces
    damage_faces = []
    damage_faces << damage_right  unless Blocks.exists?(loc.right)
    damage_faces << damage_left   unless Blocks.exists?(loc.left)
    damage_faces << damage_top    unless Blocks.exists?(loc.up)
    damage_faces << damage_bottom unless Blocks.exists?(loc.down)
    damage_faces << damage_front  unless Blocks.exists?(loc.front)
    damage_faces << damage_back   unless Blocks.exists?(loc.back)
    damage_faces
  end

  def damage_face
    strengthyness = @strength.to_f / starting_strength
    case strengthyness
    when 0.0...0.1; DamageFace9
    when 0.1...0.2; DamageFace8
    when 0.2...0.3; DamageFace7
    when 0.3...0.4; DamageFace6
    when 0.4...0.5; DamageFace5
    when 0.5...0.6; DamageFace4
    when 0.6...0.7; DamageFace3
    when 0.7...0.8; DamageFace2
    when 0.8...0.9; DamageFace1
    when 0.9...1.0; DamageFace0
    else; raise
    end
  end

  def damage_top    ; damage_face.new(frt+flt+blt+brt); end
  def damage_front  ; damage_face.new(flb+flt+frt+frb); end
  def damage_back   ; damage_face.new(brb+brt+blt+blb); end
  def damage_bottom ; damage_face.new(flb+frb+brb+blb); end
  def damage_right  ; damage_face.new(frb+frt+brt+brb); end
  def damage_left   ; damage_face.new(blb+blt+flt+flb); end

  def inspect
    "#<Block: {@loc}>"
  end
end

class GrassBlock < Block
  def starting_strength; 1; end

  def top_face    ;    GrassFace ; end
  def front_face  ; DirtSideFace ; end
  def back_face   ; DirtSideFace ; end
  def bottom_face ;     DirtFace ; end
  def right_face  ; DirtSideFace ; end
  def left_face   ; DirtSideFace ; end
end

class StoneBlock < Block
  def starting_strength; 30; end

  def top_face    ; StoneFace ; end
  def front_face  ; StoneFace ; end
  def back_face   ; StoneFace ; end
  def bottom_face ; StoneFace ; end
  def right_face  ; StoneFace ; end
  def left_face   ; StoneFace ; end
end
