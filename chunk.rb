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
    _blocks[block.loc.x][block.loc.y][block.loc.z] = block
  end

  def remove!(block)
    _blocks[block.loc.x][block.loc.y].delete(block.loc.z)
    if block == Blocks.damage_block
      Blocks.damage_block = nil
    end
  end

  def [](loc)
    _blocks[loc.x][loc.y][loc.z]
  end

  def exists?(loc)
    _blocks[loc.x][loc.y][loc.z]
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
    @blocks = Hash.new do |hx, x|
      hx[x] = Hash.new do |hy, y|
        hy[y] = {}
      end
    end

    TerrainGenerator.generate(@x_low, @z_low, SIZE, SIZE) do |x, y, z|
      loc = Point.new(x, y, z)
      add!(GrassBlock.new(loc))
    end
  end

  def fill_buffer
    @vbo = glGenBuffers(1)[0]

    blocks = _blocks.values.flat_map(&:values).flat_map(&:values).flat_map(&:faces_to_show)

    vertices = blocks.flat_map(&:vertices)
    vert_data = vertices.pack('f*')

    tex_data = blocks.map(&:tex_coords).join

    color_data = blocks.map(&:colors).join

    glBindBuffer(GL_ARRAY_BUFFER, @vbo)
    glBufferData(GL_ARRAY_BUFFER, vert_data.size+tex_data.size+color_data.size, vert_data + tex_data + color_data, GL_STATIC_DRAW)

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
