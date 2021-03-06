class Face
  attr_reader :vertices

  def initialize(vertices)
    @vertices = vertices.freeze
  end

  def self.texture(x, y)
    [x+0, y+1,
     x+0, y+0,
     x+1, y+0,
     x+1, y+1
    ].map{ |c| c/16.0 }.pack('f*').freeze
  end

  def self.colors(*rgba)
    (rgba * 4).pack('C*').freeze
  end

  COLORS = colors(255, 255, 255, 255)
  def colors
    self.class::COLORS
  end

  def tex_coords
    self.class::TEX_COORDS
  end
end

class GrassFace < Face
  COLORS = colors(77, 153, 102, 255)
  TEX_COORDS = texture(0, 0)
end

class DirtFace < Face
  TEX_COORDS = texture(2, 0)
end

class DirtSideFace < Face
  TEX_COORDS = texture(3, 0)
end

class StoneFace < Face
  TEX_COORDS = texture(1, 0)
end

class DamageFace < Face
  COLORS = colors(255, 255, 230, 255)
end

class DamageFace0 < DamageFace
  TEX_COORDS = texture(0, 15)
end
class DamageFace1 < DamageFace
  TEX_COORDS = texture(1, 15)
end
class DamageFace2 < DamageFace
  TEX_COORDS = texture(2, 15)
end
class DamageFace3 < DamageFace
  TEX_COORDS = texture(3, 15)
end
class DamageFace4 < DamageFace
  TEX_COORDS = texture(4, 15)
end
class DamageFace5 < DamageFace
  TEX_COORDS = texture(5, 15)
end
class DamageFace6 < DamageFace
  TEX_COORDS = texture(6, 15)
end
class DamageFace7 < DamageFace
  TEX_COORDS = texture(7, 15)
end
class DamageFace8 < DamageFace
  TEX_COORDS = texture(8, 15)
end
class DamageFace9 < DamageFace
  TEX_COORDS = texture(9, 15)
end
