require "bundler/setup"

require 'gosu'
require 'hasu'
require 'opengl'
require 'ruby-prof'
require 'perftools'
require 'pp'
require 'dbg'

Hasu.load 'block.rb'
Hasu.load 'blocks.rb'
Hasu.load 'player.rb'
Hasu.load 'point.rb'
Hasu.load 'terrain_generator.rb'

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

    Blocks.reset!

    start_size = 100

    @generator = TerrainGenerator.new(3)
    @generator.generate(0, 0, start_size, start_size)

    @player = Player.new
  end

  def update
    return  if @state == :paused

    @player.gravity!
    @player.forward!   if button_down?(Gosu::KbW)
    @player.backward!  if button_down?(Gosu::KbS)
    @player.sleft!     if button_down?(Gosu::KbA)
    @player.sright!    if button_down?(Gosu::KbD)
    @player.fall!

    if button_down?(Gosu::MsLeft)
      @player.dig!
    elsif Blocks.damage_block
      Blocks.damage_block.reset_strength!
    end

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

  def draw
    gl do
      glEnable(GL_TEXTURE_2D)
      glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA)
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

      Blocks.draw
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
    when Gosu::KbH
      pp GC.stat
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
    when Gosu::MsRight
      return unless @state == :playing
      empty_loc = @player.targeted_empty_loc
      if empty_loc
        block = StoneBlock.new(empty_loc)
        unless @player.colliding?(block)
          Blocks.add!(block)
        end
      end
    end
  end

  def needs_cursor?
    true
  end
end

Hasu.run(Rubycraft)
