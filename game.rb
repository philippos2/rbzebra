require "pry"

class Game
  Game::BLANK = 0
  Game::WHITE = 1
  Game::BLACK = 2
  Game::WALL  = 3

  attr_reader :board

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

    @values = [
      0,   0,   0,  0,  0,  0,  0,   0,   0,
      0,  30, -12,  0, -1, -1,  0, -12,  30,
      0, -12, -15, -3, -3, -3, -3, -15, -12,
      0,   0,  -3,  0, -1, -1,  0,  -3,   0,
      0,  -1,  -3, -1, -1, -1, -1,  -3,  -1,
      0,  -1,  -3, -1, -1, -1, -1,  -3,  -1,
      0,   0,  -3,  0, -1, -1,  0,  -3,   0,
      0, -12, -15, -3, -3, -3, -3, -15, -12,
      0,  30, -12,  0, -1, -1,  0, -12,  30,
    ]
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

  def ai_turn(turn:)
    blanks = @board.each_with_index.select {|kind, index| kind == Game::BLANK }.map {|n| n.last }

    valuations = blanks.map {|index|
      [index, test(turn: turn, index: index).map {|target| @values[target] }.inject(:+)]
    }.select {|valuation|
      valuation.last
    }.sort_by {|valuation| valuation.last }

    return false if valuations.empty?

    flip(turn: turn, index: valuations.last.first)

    true
  end

  def flip(turn:, index:)
    targets = test(turn: turn, index: index)

    return false unless targets.length > 0

    @board[index] = turn
    targets.each do |target|
      @board[target] = turn
    end

    true
  end

  def test(turn:, index:)
    targets = [-10, -9, -8, -1, 1, 8, 9, 10].map do |dir|
      test_line(turn: turn, index: index, dir: dir)
    end
    targets.flatten!
    targets.unshift(index) unless targets.empty?
    targets
  end

  private

  def test_line(turn:, index:, dir:)
    target = index + dir

    while board[target] == ((turn == Game::WHITE) ? Game::BLACK : Game::WHITE) do
      target += dir
    end

    return [] if board[target] != turn

    targets = []
    target -= dir
    while target != index do
      targets << target
      target -= dir
    end
    targets
  end
end

#### main ####

game = Game.new
game.display

loop do
  blanks = game.board.select {|index| index == Game::BLANK }.length
  blacks = game.board.select {|index| index == Game::BLACK }.length
  whites = game.board.select {|index| index == Game::WHITE }.length

  puts "blacks: #{blacks} whites: #{whites}"

  if blanks == 0
    if blacks > whites
      puts "you win !"
    elsif blacks == whites
      puts "even."
    else
      puts "you lose."
    end
    exit
  end

  print "your turn. you are BLACK(X) > "
  got = gets.chomp

  next unless got.match(/((A|B|C|D|E|F|G|H)(1|2|3|4|5|6|7|8)|quit)/)
  exit if got == "quit"

  locate = eval("Game::#{got}")
  next unless game.test(turn: Game::BLACK, index: locate).length > 0

  puts "\n==== your choice ===="
  game.flip(turn: Game::BLACK, index: locate)
  game.display

  puts "\n==== AI turn ===="
  result = game.ai_turn(turn: Game::WHITE)
  game.display

  puts "\n==== AI turn have passed. ====" unless result
end

