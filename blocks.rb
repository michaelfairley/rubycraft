Hasu.load 'chunk.rb'

module Blocks
  def self._chunks
    @chunks
  end

  def self._chunk_for_point(loc)
    x = loc.x.to_i / Chunk::SIZE * Chunk::SIZE
    z = loc.z.to_i / Chunk::SIZE * Chunk::SIZE

    _chunks[[x, z]]
  end

  def self.ensure_chunk_for_point(loc)
    x = loc.x.to_i / Chunk::SIZE * Chunk::SIZE
    z = loc.z.to_i / Chunk::SIZE * Chunk::SIZE

    _chunks.fetch([x, z]) do |x, z|
      _chunks[[x, z]] = Chunk.new(x, z)
    end
  end

  def self.exists?(loc)
    chunk = ensure_chunk_for_point(loc)
    chunk && chunk.exists?(loc)
  end

  def self._dirty_neighbors!(loc)
    loc.sides.map do |loc|
      _chunk_for_point(loc)
    end.compact.each(&:dirty!)
  end

  def self.add!(block)
    ensure_chunk_for_point(block.loc).add!(block)
    _dirty_neighbors!(block.loc)
  end

  def self.remove!(block)
    _chunk_for_point(block.loc).remove!(block)
    _dirty_neighbors!(block.loc)
  end

  def self.[](loc)
    chunk = _chunk_for_point(loc)
    chunk && chunk[loc]
  end

  def self.reset!
    _chunks.values.each(&:dirty!)  if @chunks
    @chunks = {}
  end

  def self._nearby_chunks(player)
    (-Player::SIGHT..Player::SIGHT).step(Chunk::SIZE).flat_map do |x|
      depth = Math.sqrt(Player::SIGHT**2 - x ** 2)
      (-depth..depth).step(Chunk::SIZE).map do |z|
        ensure_chunk_for_point(Point.new(x, 0, z) + player.loc)
      end
    end
  end

  def self.draw(player)
    _nearby_chunks(player).each(&:draw)

    if damage_block
      damage_block.damage_faces.each(&:draw_immediate)
    end
  end

  def self.damage_block=(damage_block)
    @damage_block = damage_block
  end

  def self.damage_block
    @damage_block
  end
end
