require "bundler/setup"

require 'gosu'
require 'hasu'
require 'opengl'
require 'ruby-prof'
require 'perftools'

Hasu.load 'block.rb'
Hasu.load 'player.rb'
Hasu.load 'point.rb'

class Rubycraft < Gosu::Window
  prepend Hasu

  WIDTH = 640
  HEIGHT = 480

  attr_reader :texture

  def initialize
    super(WIDTH, HEIGHT, false)

    @image = Gosu::Image.new(self, "terrain.png", true) # We need to hold an explicit refernce to this
    @texture = @image.gl_tex_info
    glBindTexture(GL_TEXTURE_2D, @texture.tex_name)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
  end

  def reset
    @state = :paused
    @font = Gosu::Font.new(self, Gosu.default_font_name, 30)
    glClearDepth(1.0)
    glEnable(GL_DEPTH_TEST)
    glDepthFunc(GL_LEQUAL)

    center_mouse!

    @blocks = {}

    50.times do |i|
      50.times.map do |j|
        next  if i == 1 && j == 2
        build_block(i, -1, -j)
      end
    end

    build_block(0, 1, -9)
    build_block(1, 1, -9)
    build_block(0, 0, -8)
    build_block(1, 0, -8)
    build_block(0, 0, -5)
    build_block(1, 0, -5)
    build_block(0, 0, -6)
    build_block(1, 0, -6)
    build_block(5, 0, -6)

    build_block(2, 5, -3)

    @player = Player.new(@blocks)

    if @buffers
      glDeleteBuffers(@buffers)
      @buffers = nil
    end
  end

  def build_block(x, y, z)
    block = Block.new(x, y, z, @blocks)
    @blocks[block.loc] = block
  end

  def update
    return  if @state == :paused

    @player.gravity!
    @player.forward!   if button_down?(Gosu::KbW)
    @player.backward!  if button_down?(Gosu::KbS)
    @player.sleft!     if button_down?(Gosu::KbA)
    @player.sright!    if button_down?(Gosu::KbD)
    @player.fall!

    dx = self.mouse_x - WIDTH/2
    dy = self.mouse_y - HEIGHT/2

    @player.turn!(dx)
    @player.look_up!(dy)

    center_mouse!
  end

  def center_mouse!
    self.mouse_x = WIDTH/2
    self.mouse_y = HEIGHT/2
  end

  def fill_data
    @buffers = glGenBuffers(3)
    @vert_vbo, @tex_vbo, @color_vbo = @buffers

    vertices = @blocks.values.flat_map(&:vertices)
    vert_data = vertices.pack('f*')
    glBindBuffer(GL_ARRAY_BUFFER, @vert_vbo)
    glBufferData(GL_ARRAY_BUFFER, vertices.size*4, vert_data, GL_STATIC_DRAW)

    tex_coords = @blocks.values.flat_map(&:tex_coords)
    tex_data = tex_coords.pack('f*')
    glBindBuffer(GL_ARRAY_BUFFER, @tex_vbo)
    glBufferData(GL_ARRAY_BUFFER, tex_coords.size*4, tex_data, GL_STATIC_DRAW)

    colors = @blocks.values.flat_map(&:colors)
    color_data = colors.pack('f*')
    glBindBuffer(GL_ARRAY_BUFFER, @color_vbo)
    glBufferData(GL_ARRAY_BUFFER, colors.size*4, color_data, GL_STATIC_DRAW)

    raise  unless vertices.size/3 == tex_coords.size/2
    raise  unless vertices.size/3 == colors.size/4
    @vertices_count = vertices.size/3
  end

  def draw
    fill_data  if @buffers.nil?

    gl do
      glEnable(GL_TEXTURE_2D)
      glBlendFunc(GL_SRC_ALPHA,GL_ONE)
      glShadeModel(GL_SMOOTH)
      glClearColor(0,0,0,0)
      glClearDepth(1)
      glEnable(GL_DEPTH_TEST)
      glDepthFunc(GL_LEQUAL)
      glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)
      glEnable(GL_CULL_FACE)
      glCullFace(GL_BACK)
      # glDepthRange(0, 0)

      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      glBindTexture(GL_TEXTURE_2D, @texture.tex_name)

      glMatrixMode(GL_PROJECTION)
      glLoadIdentity
      gluPerspective(45.0, width.to_f / height, 0.1, 100.0)

      glMatrixMode(GL_MODELVIEW)
      glLoadIdentity

      ambient_light = [0.8, 0.8, 0.8, 1]
      diffuse_light = [1, 1, 1, 1]
      light_postion = [0, 0, 2, 1]
      glLightfv(GL_LIGHT1, GL_AMBIENT, ambient_light)
      # glLightfv(GL_LIGHT1, GL_DIFFUSE, diffuse_light)
      # glLightfv(GL_LIGHT1, GL_POSITION, light_postion)
      # glEnable(GL_LIGHT1)
      # glEnable(GL_LIGHTING)
      glEnable(GL_COLOR_MATERIAL)

      glRotatef(@player.y_angle, 0, 1, 0)
      glRotatef(-@player.x_angle, Math.cos(@player.y_angle * Math::PI / 180), 0, Math.sin(@player.y_angle * Math::PI / 180))
      glTranslate(-@player.x, -@player.y, -@player.z)

      glColor4f(1, 1, 1, 1)

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
    end

    if @state == :paused
      @font.draw('Paused', 200, 200, 0)
    end
  end

  def button_down(button)
    case button
    when Gosu::KbP
      if @state == :playing
        @state = :paused
      elsif @state == :paused
        @state = :playing
        center_mouse!
      end
    when Gosu::KbG
      if @profiling
        @profiling = false
        result = RubyProf.stop

        printer = RubyProf::FlatPrinter.new(result)
        printer.print(STDOUT)
        # PerfTools::CpuProfiler.stop
      else
        # PerfTools::CpuProfiler.start("/tmp/rubycraft_profile")
        RubyProf.start
        @profiling = true
        puts "Profiling..."
      end
    when Gosu::KbF
      puts "FPS: #{Gosu.fps}"
    when Gosu::KbSpace
      @player.jump!
    when Gosu::MsLeft
      return unless @state == :playing
      targeted_block = @player.targeted_block
      if targeted_block
      end
    end
  end

  def needs_cursor?
    true
  end
end

Hasu.run(Rubycraft)
