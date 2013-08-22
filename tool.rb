class Tool
  def initialize
    @bob = 0
    @swing = 0
  end

  def swing!
    @swing = 20  if @swing == 0
  end

  def bob!
    @bob += 0.15
  end

  def vert_data
    @vert_data ||= @block.faces.flat_map(&:vertices).pack('f*')
  end

  def tex_data
    @tex_data ||= @block.faces.map(&:tex_coords).join
  end

  def color_data
    @color_data ||= @block.faces.map(&:colors).join
  end

  def fill_buffer
    @vbo = glGenBuffers(1)[0]
    glBindBuffer(GL_ARRAY_BUFFER, @vbo)
    glBufferData(GL_ARRAY_BUFFER, vert_data.size+tex_data.size+color_data.size, vert_data + tex_data + color_data, GL_STATIC_DRAW)
  end

  def draw
    fill_buffer unless @vbo

    glBindBuffer(GL_ARRAY_BUFFER, @vbo)

    glVertexPointer(3, GL_FLOAT, 0, 0)
    glTexCoordPointer(2, GL_FLOAT, 0, vert_data.size)
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, vert_data.size + tex_data.size)

    glDrawArrays(GL_QUADS, 0, @block.faces.flat_map(&:vertices).size)
  end
end

class Hand < Tool
  LENGTH = 0.3
  WIDTH = 0.1

  def draw
    glPushMatrix

    glTranslate(0.2, -0.25 + Math.sin(@bob)*0.02 + Math.sin(@swing/Math::PI)*0.05, -0.5)

    glRotatef(-20 + Math.sin(@bob) * 3, 0, 0, 1)
    glRotatef(-60 + Math.sin(@bob) * 5 + Math.sin(@swing/Math::PI) * 10, 1, 0, 0)
    glRotatef(Math.sin(@swing/3.0) * 30, 0, 0, 1)

    tex_coords = [[0, 0], [0, 0.25/16.0], [1/16.0, 0.25/16.0], [1/16.0, 0]] * 2
    colors = [[255, 223, 196, 255].map{|v| v/256.0}] * 8

    glBegin(GL_QUADS) do
      vertices.each_slice(3).zip(tex_coords, colors).each do |(x, y, z), (t, u), (r, g, b, a)|
        glColor4f(r, g, b, a)
        glTexCoord2f(t, u)
        glVertex3f(x, y, z)
      end
    end

    glPopMatrix

    @swing -= 1  unless @swing == 0
  end

  def vertices
    [
      # top
      0, -LENGTH, 0,
      WIDTH, -LENGTH, 0,
      WIDTH, LENGTH, 0,
      0, LENGTH, 0,
      # left
      0, LENGTH, 0,
      0, LENGTH, -WIDTH,
      0, -LENGTH, -WIDTH,
      0, -LENGTH, 0,
    ]
  end
end

class Stone < Tool
  SIZE = 0.3

  def initialize
    super
    @block = StoneBlock.new(0.3, 0.3, 0.3)
  end

  def draw
    glPushMatrix


    glTranslate(0, -0.4 + Math.sin(@bob)*0.02 + Math.sin(@swing/Math::PI)*0.05, -0.5)
    glScalef(0.25, 0.25, 0.25)

    glRotatef(-20 + Math.sin(@bob) * 3, 0, 0, 1)
    glRotatef(-60 + Math.sin(@bob) * 5 + Math.sin(@swing/Math::PI) * 5, 1, 0, 0)
    glRotatef(Math.sin(@swing/3.0) * 20, 0, 0, 1)


    # glBegin(GL_QUADS) do
    #   vertices.each_slice(3).zip(tex_coords, colors).each do |(x, y, z), (t, u), (r, g, b, a)|
    #     glColor4f(r, g, b, a)
    #     glTexCoord2f(t, u)
    #     glVertex3f(x, y, z)
    #   end
    # end

    super

    glPopMatrix

    @swing -= 1  unless @swing == 0
  end

  def vertices
    @block.faces.flat_map(&:vertices)
  end

  def colors
    @block.faces.flat_map(&:colors)
  end

  def tex_coords
    @block.faces.flat_map(&:tex_coords)
  end
end
