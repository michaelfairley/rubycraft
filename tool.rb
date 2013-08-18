class Hand
  LENGTH = 0.3
  WIDTH = 0.1

  def initialize
    @bob = 0
  end

  def draw
    glPushMatrix

    glDisable(GL_TEXTURE_2D)

    glTranslate(0.2, -0.25 + Math.sin(@bob)*0.02, -0.5)

    glRotatef(-20 + Math.sin(@bob) * 3, 0, 0, 1)
    glRotatef(-60 + Math.sin(@bob) * 5, 1, 0, 0)


    glBegin(GL_QUADS) do
      glColor4f(0.5, 0, 0, 1)

      vertices.each_slice(3) do |x, y, z|
        glVertex3f(x, y, z)
      end
    end

    glEnable(GL_TEXTURE_2D)


    glPopMatrix
  end

  def bob!
    @bob += 0.15
  end

  def vertices
    [
      # top
      0, 0, 0,
      WIDTH, 0, 0,
      WIDTH, LENGTH, 0,
      0, LENGTH, 0,
      # left
      0, 0, 0,
      0, LENGTH, 0,
      0, LENGTH, -WIDTH,
      0, 0, -WIDTH,
    ]
  end
end
