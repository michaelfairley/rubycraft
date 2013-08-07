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
    if @vbo
      glDeleteBuffers(@vbo)
      @vbo = nil
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

  def fill_buffer
    @vbo = glGenBuffers(1)[0]

    vertices = _blocks.values.flat_map(&:vertices)
    vert_data = vertices.pack('f*')

    tex_coords = _blocks.values.flat_map(&:tex_coords)
    tex_data = tex_coords.pack('f*')

    colors = _blocks.values.flat_map(&:colors)
    color_data = colors.pack('C*')

    glBindBuffer(GL_ARRAY_BUFFER, @vbo)
    glBufferData(GL_ARRAY_BUFFER, vertices.size*4+tex_coords.size*4+colors.size*4, vert_data + tex_data + color_data, GL_STATIC_DRAW)


    raise  unless vertices.size/3 == tex_coords.size/2
    raise  unless vertices.size/3 == colors.size/4
    @vertices_count = vertices.size/3
  end

  def draw
    fill_buffer  if @vbo.nil?

    glBindBuffer(GL_ARRAY_BUFFER, @vbo)

    glVertexPointer(3, GL_FLOAT, 0, 0)
    glTexCoordPointer(2, GL_FLOAT, 0, @vertices_count*3*4)
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, @vertices_count*3*4 + @vertices_count*2*4)

    glDrawArrays(GL_QUADS, 0, @vertices_count)
  end
end
