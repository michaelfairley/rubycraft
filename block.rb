Hasu.load "blocks.rb"
Hasu.load "face.rb"

class Block
  attr_reader :x, :y, :z

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
    reset_strength!
  end

  def reset_strength!
    @strength = starting_strength
  end

  def x1; @x1 ||= x-0.5 ; end
  def x2; @x2 ||= x+0.5 ; end
  def y1; @y1 ||= y-0.5 ; end
  def y2; @y2 ||= y+0.5 ; end
  def z1; @z1 ||= z-0.5 ; end
  def z2; @z2 ||= z+0.5 ; end

  def faces
    [right, left, top, bottom, back, front]
  end

  def faces_to_show
    faces = []
    faces << right  unless Blocks.exists?(x+1, y, z)
    faces << left   unless Blocks.exists?(x-1, y, z)
    faces << top    unless Blocks.exists?(x, y+1, z)
    faces << bottom unless Blocks.exists?(x, y-1, z)
    faces << back   unless Blocks.exists?(x, y, z+1)
    faces << front  unless Blocks.exists?(x, y, z-1)
    faces
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

  def dig!
    Blocks.damage_block = self
    @strength -= 1
    if @strength <= 0
      Blocks.remove!(self)
      Blocks.damage_block = nil
    end
  end

  def strength_ratio
    @strength.to_f / starting_strength
  end

  def draw_damage
    DamageBlock.new(self).draw
  end

  def inspect
    "#<Block: {@loc}>"
  end
end

require 'forwardable'

class DamageBlock
  extend Forwardable

  def_delegators :@block, :x, :y, :z, :blb, :brb, :flb, :frb, :blt, :brt, :flt, :frt, :strength_ratio

  def initialize(block)
    @block = block
  end

  def blend(&blk)
    glEnable(GL_BLEND)
    yield
  ensure
    glDisable(GL_BLEND)
  end

  def temp_vbo(&blk)
    vbo = glGenBuffers(1)[0]
    yield vbo
  ensure
    glDeleteBuffers(vbo)
  end

  def vert_data
    @vert_data ||= faces.flat_map(&:vertices).pack('f*')
  end

  def tex_data
    @tex_data ||= faces.map(&:tex_coords).join
  end

  def color_data
    @color_data ||= faces.map(&:colors).join
  end

  def fill_buffer(vbo)
    glBindBuffer(GL_ARRAY_BUFFER, vbo)
    glBufferData(GL_ARRAY_BUFFER, vert_data.size+tex_data.size+color_data.size, vert_data + tex_data + color_data, GL_STATIC_DRAW)
  end

  def draw_buffer(vbo)
    glBindBuffer(GL_ARRAY_BUFFER, vbo)

    glVertexPointer(3, GL_FLOAT, 0, 0)
    glTexCoordPointer(2, GL_FLOAT, 0, vert_data.size)
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, vert_data.size + tex_data.size)

    glDrawArrays(GL_QUADS, 0, faces.flat_map(&:vertices).size)
  end

  def draw
    blend do
      temp_vbo do |vbo|
        fill_buffer(vbo)
        draw_buffer(vbo)
      end
    end
  end

  def faces
    @faces ||= [right, left, top, bottom, front, back]
  end

  def face
    case strength_ratio
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

  def top    ; face.new(frt+flt+blt+brt); end
  def front  ; face.new(flb+flt+frt+frb); end
  def back   ; face.new(brb+brt+blt+blb); end
  def bottom ; face.new(flb+frb+brb+blb); end
  def right  ; face.new(frb+frt+brt+brb); end
  def left   ; face.new(blb+blt+flt+flb); end
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
  def starting_strength; 10; end

  def top_face    ; StoneFace ; end
  def front_face  ; StoneFace ; end
  def back_face   ; StoneFace ; end
  def bottom_face ; StoneFace ; end
  def right_face  ; StoneFace ; end
  def left_face   ; StoneFace ; end
end
