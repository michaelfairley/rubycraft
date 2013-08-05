# A Chunk contains a group of blocks that exist within some range of x & z
# coordiantes. Chunk exists mainly as a performance optimization, making it so
# we only need to repack VBOs for a subset of blocks when there is a change to
# the blocks.
class Chunk
  SIZE = 10

  def initialize(x_low, z_low)
    @x_low = x_low
    @z_low = z_low
  end

  def add!(block)
    _blocks[block.loc] = block
  end

  def remove!(block)
    _blocks.delete(block.loc)
    if block == Blocks.damage_block
      Blocks.damage_block = nil
    end
  end

  def [](*args)
    _blocks[*args]
  end

  def exists?(loc)
    _blocks.has_key?(loc)
  end

  def dirty!
    if @buffers
      glDeleteBuffers(@buffers)
      @buffers = nil
    end
  end

  def _blocks
    _generate_blocks  if @blocks.nil?
    @blocks
  end

  def _generate_blocks
    @blocks = {}

    TerrainGenerator.generate(@x_low, @z_low, SIZE, SIZE) do |x, y, z|
      loc = Point.new(x, y, z)
      add!(GrassBlock.new(loc))
    end
  end

  def fill_buffers
    @buffers = glGenBuffers(3)
    @vert_vbo, @tex_vbo, @color_vbo = @buffers

    vertices = _blocks.values.flat_map(&:vertices)
    vert_data = vertices.pack('f*')
    glBindBuffer(GL_ARRAY_BUFFER, @vert_vbo)
    glBufferData(GL_ARRAY_BUFFER, vertices.size*4, vert_data, GL_STATIC_DRAW)

    tex_coords = _blocks.values.flat_map(&:tex_coords)
    tex_data = tex_coords.pack('f*')
    glBindBuffer(GL_ARRAY_BUFFER, @tex_vbo)
    glBufferData(GL_ARRAY_BUFFER, tex_coords.size*4, tex_data, GL_STATIC_DRAW)

    colors = _blocks.values.flat_map(&:colors)
    color_data = colors.pack('f*')
    glBindBuffer(GL_ARRAY_BUFFER, @color_vbo)
    glBufferData(GL_ARRAY_BUFFER, colors.size*4, color_data, GL_STATIC_DRAW)

    raise  unless vertices.size/3 == tex_coords.size/2
    raise  unless vertices.size/3 == colors.size/4
    @vertices_count = vertices.size/3
  end

  def draw
    fill_buffers  if @buffers.nil?

    glBindBuffer(GL_ARRAY_BUFFER, @vert_vbo)
    glVertexPointer(3, GL_FLOAT, 0, 0)

    glBindBuffer(GL_ARRAY_BUFFER, @tex_vbo)
    glTexCoordPointer(2, GL_FLOAT, 0, 0)

    glBindBuffer(GL_ARRAY_BUFFER, @color_vbo)
    glColorPointer(4, GL_FLOAT, 0, 0)

    glDrawArrays(GL_QUADS, 0, @vertices_count)
  end
end
