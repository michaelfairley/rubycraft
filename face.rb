class Face
  attr_reader :vertices

  def initialize(vertices)
    @vertices = vertices.freeze
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

  TEX_COORDS = [0, 1, 0, 0, 1, 0, 1, 1].map{ |c| c/16.0 }.freeze
  def tex_coords
    TEX_COORDS
  end
end

class DirtFace < Face
  TEX_COORDS = [2, 1, 2, 0, 3, 0, 3, 1].map{ |c| c/16.0 }.freeze
  def tex_coords
    TEX_COORDS
  end
end

class DirtSideFace < Face
  TEX_COORDS = [3, 1, 3, 0, 4, 0, 4, 1].map{ |c| c/16.0 }.freeze
  def tex_coords
    TEX_COORDS
  end
end
