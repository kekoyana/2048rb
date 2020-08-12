# frozen_string_literal: true

class Game
  class Clear < StandardError; end
  class Over < StandardError; end

  INPUTS = {
    q: :move_left,
    w: :move_up,
    e: :move_down,
    r: :move_right,
    z: :abort
  }.freeze

  def start
    @board = Board.new
    print
    loop { game }
  end

  private

  def print
    puts "\e[H\e[2J"
    puts @board.status
    puts @board.to_s
  end

  def game
    input = wait_input
    abort 'give up!' if input == 'z'

    @board.send(INPUTS[input.to_sym])
    @board.win?
    game_check

    print
  end

  def game_check
    case @board.status
    when Board::STATUS_WIN
      puts 'win!'
      exit
    when Board::STATUS_LOSE
      puts 'lose ...'
      exit
    end
  end

  def wait_input
    input = ''
    dirs = INPUTS.keys.map(&:to_s)
    input = $stdin.getch until dirs.include?(input)
    input
  end
end
