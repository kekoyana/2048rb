# frozen_string_literal: true

class Board
  attr_accessor :status

  STATUS_WIN = :win
  STATUS_LOSE = :lose
  COLORS = [0, 2, 4, 8, 16, 32, 64, 128, 256, 1024, 2048].zip(
    %i[black white red green blue yellow magenta cyan gray red green]
  ).to_h

  def initialize
    @tiles = Array.new(4) { Array.new(4) { 0 } }

    2.times { add_right_tile }
  end

  def win?
    @status = STATUS_WIN if @tiles.flatten.include?(2048)
  end

  # 左に動かす
  def move_left
    tmp_tiles = @tiles.flatten.join(',')
    @tiles = tiles_move(@tiles)

    # 動きがないのでなにもしない
    return if @tiles.flatten.join(',') == tmp_tiles

    add_right_tile
    @status = STATUS_LOSE if @tiles.flatten.join(',') == tmp_tiles
  end

  def move_right
    @tiles.each(&:reverse!)
    move_left.tap do
      @tiles.each(&:reverse!)
    end
  end

  def move_down
    @tiles = @tiles.transpose.map(&:reverse)
    move_left.tap do
      @tiles = @tiles.transpose.map(&:reverse)
      @tiles = @tiles.transpose.map(&:reverse)
      @tiles = @tiles.transpose.map(&:reverse)
    end
  end

  def move_up
    @tiles = @tiles.transpose.map(&:reverse)
    @tiles = @tiles.transpose.map(&:reverse)
    @tiles = @tiles.transpose.map(&:reverse)
    move_left.tap do
      @tiles = @tiles.transpose.map(&:reverse)
    end
  end

  def to_s
    @tiles.map do |tiles|
      tiles.map { sprint_tile(_1) }.join('|') + "\n"
    end
  end

  def sprint_tile(tile)
    HighLine.color(format('%<tile> 4d', tile: tile), COLORS[tile], tile >= 1024 ? :bold : nil)
  end

  private

  # 右にtileを追加する
  def add_right_tile
    tile_num = [2, 4].sample # 2 or 4 を追加する
    4.times.to_a.shuffle.each do |i|
      if @tiles[i][3].zero?
        @tiles[i][3] = tile_num
        return true
      end
    end
    false
  end

  def tiles_move(board_tiles)
    board_tiles.map do |tiles|
      tiles.reject(&:zero?)
           .then { tile_lines_sum(_1) }
           .reject(&:zero?)
           .then { _1.fill(0, _1.size..3) }
    end
  end

  # tileの加算計算
  def tile_lines_sum(tile_lines)
    3.times do |i|
      next if tile_lines[i].nil? || tile_lines[i].zero?

      if tile_lines[i] == tile_lines[i + 1]
        tile_lines[i] *= 2
        tile_lines[i + 1] = 0
      end
    end
    tile_lines
  end
end
