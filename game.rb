#! /bin/sh
exec ruby -S -x "$0" "$@"
#! ruby

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

  def puttable?(turn:, index: nil)
    if index.nil?
      blanks = @board.each_with_index.select {|kind, index| kind == Game::BLANK }.map {|n| n.last }
      !blanks.select {|index| !loot(turn: turn, index: index).empty? }.empty?
    else
      loot(turn: Game::BLACK, index: index).length > 0
    end
  end

  def ai_turn(turn:)
    valuations = valuate(turn: turn)

    return false if valuations.empty?

    flip(turn: turn, index: valuations.last.first)

    true
  end

  def flip(turn:, index:)
    loots = loot(turn: turn, index: index)

    return false unless loots.length > 0

    @board[index] = turn
    loots.each do |loot|
      @board[loot] = turn
    end

    true
  end

  private

  def valuate(turn:)
    blanks = @board.each_with_index.select {|kind, index| kind == Game::BLANK }.map {|n| n.last }

    valuations = blanks.map {|index|
      [index, loot(turn: turn, index: index).map {|loot| @values[loot] }.inject(:+)]
    }.select {|valuation|
      valuation.last
    }.map {|valuation|
      [valuation.first, valuation.last + @values[valuation.first]]
    }.sort_by {|valuation| valuation.last }
  end

  def loot(turn:, index:)
    loots = [-10, -9, -8, -1, 1, 8, 9, 10].map do |direction|
      loot_line(turn: turn, index: index, direction: direction)
    end
    loots.flatten
  end

  def loot_line(turn:, index:, direction:)
    marker = index + direction

    while board[marker] == ((turn == Game::WHITE) ? Game::BLACK : Game::WHITE) do
      marker += direction
    end

    return [] if board[marker] != turn

    loots = []
    marker -= direction
    while marker != index do
      loots << marker
      marker -= direction
    end
    loots
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

  print "your turn. you are BLACK(X)\nselect cell, pass, quit or display > "
  got = gets.chomp

  next unless got.match(/((A|B|C|D|E|F|G|H)(1|2|3|4|5|6|7|8)|display|pass|quit)/)

  case got
  when "quit" then
    exit
  when "display" then
    game.display
    next
  when "pass" then
    unless game.puttable?(turn: Game::BLACK)
      puts "pass !"
    else
      puts "you can't pass. try again."
      game.display
      next
    end
  else
    index = eval("Game::#{got}")
    next unless game.puttable?(turn: Game::BLACK, index: index)

    puts "\n==== your choice ===="
    game.flip(turn: Game::BLACK, index: index)
    game.display
  end

  puts "\n==== AI turn ===="
  result = game.ai_turn(turn: Game::WHITE)
  game.display

  puts "\n==== AI passed. ====" unless result
end

