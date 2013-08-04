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
    ].map{ |c| c/16.0 }.freeze
  end

  COLORS = ([1, 1, 1, 1] * 4).freeze
  def colors
    COLORS
  end
end

class GrassFace < Face
  COLORS = ([0.3, 0.6, 0.4, 1] * 4).freeze
  def colors
    COLORS
  end

  TEX_COORDS = texture(0, 0)
  def tex_coords
    TEX_COORDS
  end
end

class DirtFace < Face
  TEX_COORDS = texture(2, 0)
  def tex_coords
    TEX_COORDS
  end
end

class DirtSideFace < Face
  TEX_COORDS = texture(3, 0)
  def tex_coords
    TEX_COORDS
  end
end

class StoneFace < Face
  TEX_COORDS = texture(1, 0)
  def tex_coords
    TEX_COORDS
  end
end
