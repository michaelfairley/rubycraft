module Blocks
  def self._blocks
    @blocks || {}
  end

  def self.reset!
    @blocks = {}
    _dirty!
  end

  def self.create!(x, y, z)
    block = GrassBlock.new(Point.new(x, y, z))
    add!(block)
  end

  def self.add!(block)
    _blocks[block.loc] = block
    block.loc.sides.map{|l| _blocks[l] }.compact.each(&:dirty!)
    _dirty!
  end

  def self.remove!(block)
    _blocks.delete(block.loc)
    if block == damage_block
      self.damage_block = nil
    end
    block.loc.sides.map{|l| _blocks[l] }.compact.each(&:dirty!)
    _dirty!
  end

  def self.exists?(loc)
    _blocks.has_key?(loc)
  end

  def self.[](*args)
    _blocks[*args]
  end

  def self._dirty!
    if @buffers
      glDeleteBuffers(@buffers)
      @buffers = nil
    end
  end

  def self.fill_buffers
    @buffers = glGenBuffers(3)
    @vert_vbo, @tex_vbo, @color_vbo = @buffers

    vertices = Blocks._blocks.values.flat_map(&:vertices)
    vert_data = vertices.pack('f*')
    glBindBuffer(GL_ARRAY_BUFFER, @vert_vbo)
    glBufferData(GL_ARRAY_BUFFER, vertices.size*4, vert_data, GL_STATIC_DRAW)

    tex_coords = Blocks._blocks.values.flat_map(&:tex_coords)
    tex_data = tex_coords.pack('f*')
    glBindBuffer(GL_ARRAY_BUFFER, @tex_vbo)
    glBufferData(GL_ARRAY_BUFFER, tex_coords.size*4, tex_data, GL_STATIC_DRAW)

    colors = Blocks._blocks.values.flat_map(&:colors)
    color_data = colors.pack('f*')
    glBindBuffer(GL_ARRAY_BUFFER, @color_vbo)
    glBufferData(GL_ARRAY_BUFFER, colors.size*4, color_data, GL_STATIC_DRAW)

    raise  unless vertices.size/3 == tex_coords.size/2
    raise  unless vertices.size/3 == colors.size/4
    @vertices_count = vertices.size/3
  end

  def self.draw
    fill_buffers  if @buffers.nil?

    glBindBuffer(GL_ARRAY_BUFFER, @vert_vbo)
    glVertexPointer(3, GL_FLOAT, 0, 0)

    glBindBuffer(GL_ARRAY_BUFFER, @tex_vbo)
    glTexCoordPointer(2, GL_FLOAT, 0, 0)

    glBindBuffer(GL_ARRAY_BUFFER, @color_vbo)
    glColorPointer(4, GL_FLOAT, 0, 0)

    glEnableClientState(GL_VERTEX_ARRAY)
    glEnableClientState(GL_TEXTURE_COORD_ARRAY)
    glEnableClientState(GL_COLOR_ARRAY)

    glDrawArrays(GL_QUADS, 0, @vertices_count)

    glDisableClientState(GL_VERTEX_ARRAY)
    glDisableClientState(GL_TEXTURE_COORD_ARRAY)
    glDisableClientState(GL_COLOR_ARRAY)

    if damage_block
      damage_block.damage_faces.each(&:draw_immediate)
    end
  end

  def self.damage_block=(damage_block)
    @damage_block = damage_block
  end

  def self.damage_block
    @damage_block
  end
end
