class Hand
  LENGTH = 0.3
  WIDTH = 0.1

  def initialize
    @bob = 0
    @swing = 0
  end

  def swing!
    @swing = 20  if @swing == 0
  end

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

  def bob!
    @bob += 0.15
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
