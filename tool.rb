class Hand
  LENGTH = 0.3
  WIDTH = 0.1

  def initialize
    @bob = 0
    @swing = 0
  end

  def swing!
    @swing = 30  if @swing == 0
  end

  def draw
    glPushMatrix

    glDisable(GL_TEXTURE_2D)

    glTranslate(0.2, -0.25 + Math.sin(@bob)*0.02 + Math.sin(@swing/Math::PI)*0.05, -0.5)

    glRotatef(-20 + Math.sin(@bob) * 3, 0, 0, 1)
    glRotatef(-60 + Math.sin(@bob) * 5 + Math.sin(@swing/Math::PI) * 10, 1, 0, 0)
    glRotatef(Math.sin(@swing/3.0) * 40, 0, 0, 1)


    glBegin(GL_QUADS) do
      glColor4f(0.5, 0, 0, 1)

      vertices.each_slice(3) do |x, y, z|
        glVertex3f(x, y, z)
      end
    end

    glEnable(GL_TEXTURE_2D)


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
      0, -LENGTH, 0,
      0, LENGTH, 0,
      0, LENGTH, -WIDTH,
      0, -LENGTH, -WIDTH,
    ]
  end
end
