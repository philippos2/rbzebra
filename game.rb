require "pry"

class Game
  Game::BLANK = 0
  Game::WHITE = 1
  Game::BLACK = 2
  Game::WALL  = 3

  attr_accessor :board, :turn, :turn_count, :whites, :blacks

  def initialize
    width = ["A", "B", "C", "D", "E", "F", "G", "H"]
    (90).times.each do |n|
      eval("Game::#{width[n % 9 - 1]}#{n / 9} = #{n}") if (n / 9) > 0 && (n / 9) < 9 && (n % 9) != 0
    end

    @board = (90).times.map do |n|
      (n / 9) > 0 && (n / 9) < 9 && (n % 9) != 0 ? Game::BLANK : Game::WALL
    end

    @board[Game::D4] = Game::WHITE
    @board[Game::D5] = Game::BLACK
    @board[Game::E4] = Game::BLACK
    @board[Game::E5] = Game::WHITE

    @turn = Game::WHITE
    @turn_count = 0
    @whites = 2
    @blacks = 2
  end

  def display
    puts "  A B C D E F G H"
    (1..8).each do |n|
      puts @board.slice(n * 9, 9).join(" ")
        .gsub(/#{Game::BLANK}/, "-")
        .gsub(/#{Game::WHITE}/, "O")
        .gsub(/#{Game::BLACK}/, "X")
        .gsub(/#{Game::WALL}/,  (n % 9).to_s)
    end
  end

  def flip(turn:, index:)
    [-10, -9, -8, -1, 1, 8, 9, 10].each do |dir|
      flip_line(turn: turn, index: index, dir: dir)
    end

    @board[index] = turn
  end

  private

  def flip_line(turn:, index:, dir:)
    target = index + dir

    while board[target] == ((turn == Game::WHITE) ? Game::BLACK : Game::WHITE) do
      target += dir
    end

    return 0 if board[target] != turn

    flips = 0
    target -= dir
    while target != index do
      board[target] = turn
      target -= dir
      flips += 1
    end

    flips
  end

end

game = Game.new
game.display


game.flip(turn: Game::BLACK, index: Game::D3)
game.display

game.flip(turn: Game::WHITE, index: Game::E3)
game.display

game.flip(turn: Game::BLACK, index: Game::F3)
game.display



