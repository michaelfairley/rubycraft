Hasu.load "point.rb"

class Block
  attr_reader :loc

  def initialize(x, y, z, blocks)
    @loc = Point.new(x, y, z)
    @blocks = blocks
  end

  def x1; @x1 ||= loc.x-0.5 ; end
  def x2; @x2 ||= loc.x+0.5 ; end
  def y1; @y1 ||= loc.y-0.5 ; end
  def y2; @y2 ||= loc.y+0.5 ; end
  def z1; @z1 ||= loc.z-0.5 ; end
  def z2; @z2 ||= loc.z+0.5 ; end

  N = -0.5
  P =  0.5
  FLB = [N, N, N]
  FLT = [N, P, N]
  FRB = [P, N, N]
  FRT = [P, P, N]
  BLB = [N, N, P]
  BLT = [N, P, P]
  BRB = [P, N, P]
  BRT = [P, P, P]

  module TEX_COORDS
    TOP    = [[0.0/16, 0.0/16], [0.0/16, 1.0/16], [1.0/16, 1.0/16], [1.0/16, 0.0/16]]
    SIDE   = [[3.0/16, 0.0/16], [3.0/16, 1.0/16], [4.0/16, 1.0/16], [4.0/16, 0.0/16]]
    BOTTOM = [[2.0/16, 0.0/16], [2.0/16, 1.0/16], [3.0/16, 1.0/16], [3.0/16, 0.0/16]]
  end

  LISTS = {}

  def faces_to_show
    return @faces  if @faces
    @faces = []
    @faces << LISTS.fetch(:right)  unless @blocks.has_key?(loc.right)
    @faces << LISTS.fetch(:left)   unless @blocks.has_key?(loc.left)
    @faces << LISTS.fetch(:top)    unless @blocks.has_key?(loc.up)
    @faces << LISTS.fetch(:bottom) unless @blocks.has_key?(loc.down)
    @faces << LISTS.fetch(:front)  unless @blocks.has_key?(loc.front)
    @faces << LISTS.fetch(:back)   unless @blocks.has_key?(loc.back)
    @faces
  end

  def draw
    self.class.compile_lists

    glPushMatrix
    glTranslate(loc.x, loc.y, loc.z)

    glCallLists(GL_INT, faces_to_show)

    glPopMatrix
  end

  def inspect
    "#<Block: {@loc}>"
  end

  def self.compile_top_list
    LISTS[:top] = next_list_id

    glNewList(LISTS[:top], GL_COMPILE)

    glBegin(GL_QUADS)
      glColor4f(0.3, 0.6, 0.4, 1)
      glTexCoord2f(*TEX_COORDS::TOP[0])
      glVertex3f(*FRT)
      glTexCoord2f(*TEX_COORDS::TOP[1])
      glVertex3f(*FLT)
      glTexCoord2f(*TEX_COORDS::TOP[2])
      glVertex3f(*BLT)
      glTexCoord2f(*TEX_COORDS::TOP[3])
      glVertex3f(*BRT)
    glEnd

    glEndList
  end

  def self.compile_front_list
    LISTS[:front] = next_list_id

    glNewList(LISTS[:front], GL_COMPILE)

    glBegin(GL_QUADS)
      glColor4f(1, 1, 1, 1)
      glTexCoord2f(*TEX_COORDS::SIDE[0])
      glVertex3f(*FRT)
      glTexCoord2f(*TEX_COORDS::SIDE[1])
      glVertex3f(*FRB)
      glTexCoord2f(*TEX_COORDS::SIDE[2])
      glVertex3f(*FLB)
      glTexCoord2f(*TEX_COORDS::SIDE[3])
      glVertex3f(*FLT)
    glEnd

    glEndList
  end

  def self.compile_right_list
    LISTS[:right] = next_list_id

    glNewList(LISTS[:right], GL_COMPILE)

    glBegin(GL_QUADS)
      glColor4f(1, 1, 1, 1)
      glTexCoord2f(*TEX_COORDS::SIDE[0])
      glVertex3f(*BRT)
      glTexCoord2f(*TEX_COORDS::SIDE[1])
      glVertex3f(*BRB)
      glTexCoord2f(*TEX_COORDS::SIDE[2])
      glVertex3f(*FRB)
      glTexCoord2f(*TEX_COORDS::SIDE[3])
      glVertex3f(*FRT)
    glEnd

    glEndList
  end

  def self.compile_left_list
    LISTS[:left] = next_list_id

    glNewList(LISTS[:left], GL_COMPILE)

    glBegin(GL_QUADS)
      glColor4f(1, 1, 1, 1)
      glTexCoord2f(*TEX_COORDS::SIDE[0])
      glVertex3f(*FLT)
      glTexCoord2f(*TEX_COORDS::SIDE[1])
      glVertex3f(*FLB)
      glTexCoord2f(*TEX_COORDS::SIDE[2])
      glVertex3f(*BLB)
      glTexCoord2f(*TEX_COORDS::SIDE[3])
      glVertex3f(*BLT)
    glEnd

    glEndList
  end

  def self.compile_back_list
    LISTS[:back] = next_list_id

    glNewList(LISTS[:back], GL_COMPILE)

    glBegin(GL_QUADS)
      glColor4f(1, 1, 1, 1)
      glTexCoord2f(*TEX_COORDS::SIDE[0])
      glVertex3f(*BLT)
      glTexCoord2f(*TEX_COORDS::SIDE[1])
      glVertex3f(*BLB)
      glTexCoord2f(*TEX_COORDS::SIDE[2])
      glVertex3f(*BRB)
      glTexCoord2f(*TEX_COORDS::SIDE[3])
      glVertex3f(*BRT)
    glEnd

    glEndList
  end

  def self.compile_bottom_list
    LISTS[:bottom] = next_list_id

    glNewList(LISTS[:bottom], GL_COMPILE)

    glBegin(GL_QUADS)
      glColor4f(1, 1, 1, 1)
      glTexCoord2f(*TEX_COORDS::BOTTOM[0])
      glVertex3f(*FLB)
      glTexCoord2f(*TEX_COORDS::BOTTOM[1])
      glVertex3f(*FRB)
      glTexCoord2f(*TEX_COORDS::BOTTOM[2])
      glVertex3f(*BRB)
      glTexCoord2f(*TEX_COORDS::BOTTOM[3])
      glVertex3f(*BLB)
    glEnd

    glEndList
  end

  def self.compile_lists
    return  unless dirty?
    @@list_counter = glGenLists(6)
    compile_top_list
    compile_front_list
    compile_left_list
    compile_right_list
    compile_back_list
    compile_bottom_list
    @dirty = false
  end

  def self.dirty!
    @dirty = true
  end

  def self.dirty?
    @dirty
  end

  def self.next_list_id
    @@list_counter +=1
    @@list_counter - 1
  end

  self.dirty!
end
