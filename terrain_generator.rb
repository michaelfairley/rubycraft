require "perlin"

class TerrainGenerator
  SEED = 1

  TINY_INTERVAL = 0.1
  SMALL_INTERVAL = 0.05
  BIG_INTERVAL = 0.005

  TINY_GEN  = Perlin::Generator.new(SEED, 0.5, 5)
  SMALL_GEN = Perlin::Generator.new(SEED, 0.5, 5)
  BIG_GEN   = Perlin::Generator.new(SEED, 0.25, 5)

  def self.generate(x1, z1, x_size, z_size, &blk)
    tiny_noise  =  TINY_GEN.chunk(TINY_INTERVAL*x1, TINY_INTERVAL*z1, x_size, z_size, TINY_INTERVAL)
    small_noise = SMALL_GEN.chunk(SMALL_INTERVAL*x1, SMALL_INTERVAL*z1, x_size, z_size, SMALL_INTERVAL)
    big_noise   =   BIG_GEN.chunk(BIG_INTERVAL*x1, BIG_INTERVAL*z1, x_size, z_size, BIG_INTERVAL)

    x_size.times do |i|
      z_size.times do |j|
        y = tiny_noise[i][j] + small_noise[i][j] * 3 + big_noise[i][j] * 16
        yield(x1+i, y.to_i, z1+j)
      end
    end
  end
end
