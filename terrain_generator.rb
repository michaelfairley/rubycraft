require "perlin"

class TerrainGenerator
  def initialize(seed)
    @tiny_gen = Perlin::Generator.new(seed, 0.5, 5)
    @small_gen = Perlin::Generator.new(seed, 0.5, 5)
    @big_gen = Perlin::Generator.new(seed, 0.25, 5)
  end

  def generate(x1, z1, x_size, z_size)
    tiny_noise  =  @tiny_gen.chunk(x1, z1, x_size, z_size, 0.1)
    small_noise = @small_gen.chunk(x1, z1, x_size, z_size, 0.05)
    big_noise   =   @big_gen.chunk(x1, z1, x_size, z_size, 0.005)

    x_size.times do |i|
      z_size.times do |j|
        y = tiny_noise[i][j] + small_noise[i][j] * 3 + big_noise[i][j] * 16
        Blocks.create!(i, y.to_i, -j)
      end
    end
  end
end
