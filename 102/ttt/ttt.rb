class Board
  ROWS = [[1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
          [1, 4, 7],
          [2, 5, 8],
          [3, 6, 9],
          [1, 5, 9],
          [3, 5, 7]].freeze

  attr_accessor :squares

  def initialize
    @squares = {}
    reset
  end

  def reset
    (1..9).each { |number| squares[number] = Square.new(number.to_s) }
  end

  def display
    puts "       |       |      "
    puts "   #{squares[1]}   |   #{squares[2]}   |   #{squares[3]}   "
    puts "       |       |      "
    puts "----------------------"
    puts "       |       |      "
    puts "   #{squares[4]}   |   #{squares[5]}   |   #{squares[6]}   "
    puts "       |       |      "
    puts "----------------------"
    puts "       |       |      "
    puts "   #{squares[7]}   |   #{squares[8]}   |   #{squares[9]}   "
    puts "       |       |      "
  end

  def clear
    system "clear"
  end

  def display_and_clear
    clear
    display
  end

  def []=(square, symbol)
    squares[square].symbol = symbol
  end

  def blank_squares
    squares.select { |square, _| squares[square].empty? }.keys
  end

  def full?
    squares.none? { |square, _| squares[square].empty? }
  end

  def show_blank_squares
    puts "Empty squares - #{blank_squares}"
  end

  def winning_symbol
    ROWS.each do |row|
      Square::SYMBOLS.each do |symbol|
        if squares.values_at(*row).map(&:symbol).count(symbol) == 3
          return symbol 
        end
      end
    end
    nil   
  end

  def two_in_row(symbol)
    ROWS.each do |row|
      if squares.values_at(*row).map(&:symbol).count(symbol) == 2
        row.each { |square| return square if squares[square].empty? }
      end
    end
    nil
  end
end

class Square
  SYMBOLS = %w(X O).freeze

  attr_accessor :symbol

  def self.valid?(input)
    ("1".."9").cover?(input)
  end

  def initialize(symbol)
    @symbol = symbol
  end

  def to_s
    @symbol
  end

  def empty?
    ("1".."9").cover?(symbol)
  end
end

class Player
  attr_accessor :symbol, :order, :name
end

class Human < Player
  def initialize
    @name = enter_name
    @symbol = pick_symbol
    random_order
  end

  def random_order
    @order = [1, 2].sample
  end

  def enter_name
    input = ""
    puts "Enter your name."
    loop do
      input = gets.strip
      break unless input.empty?
      puts "Please enter a name."
    end
  end

  def pick_symbol
    input = ""
    puts "Pick your symbol - Enter 'X' or 'O'."
    loop do
      input = gets.strip
      input = input.upcase
      break if Square::SYMBOLS.include?(input)
      puts "Please enter only 'X' or 'O'."
    end
    input
  end

  def place_symbol(board)
    input = ""
    puts "Pick a number between 1 to 9 to place #{symbol} in a square."
    loop do
      board.show_blank_squares
      input = gets.strip
      valid = Square.valid?(input)
      empty = board.blank_squares.include?(input.to_i)
      break if valid && empty
      puts "#{input} isn't a valid square." unless valid
      puts "#{input} is full." unless empty
    end
    board[input.to_i] = symbol
  end
end

class Computer < Player
  def initialize
    @name = "Computer"
  end

  def assign_stats(human)
    assign_symbol(human.symbol)
    assign_order(human.order)
  end

  def assign_symbol(human_symbol)
    @symbol = "O" if human_symbol == "X"
    @symbol = "X" if human_symbol == "O"
  end

  def assign_order(human_order)
    @order = 1 if human_order == 2
    @order = 2 if human_order == 1
  end

  def place_symbol(board)
    if board.two_in_row(symbol)
      fill_winning_row(board)
    elsif board.squares[5].empty?
      fill_center_square(board)
    else
      fill_random_square(board) 
    end
  end

  def fill_center_square(board)
    board[5] = symbol
    print_move(5)
  end

  def fill_winning_row(board)
    winning_square = board.two_in_row(symbol)
    board[winning_square] = symbol
    print_move(winning_square)
  end

  def fill_random_square(board)
    square = board.blank_squares.sample
    board[square] = symbol
    print_move(square)
  end

  def print_move(square)
    puts "Computer picked #{square}"
  end
end

class Game
  attr_accessor :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Human.new
    @computer = Computer.new
  end

  def play
    setup(human)
    loop do
      loop do
        player_turn(1, board)
        break if end_conditions
        player_turn(2, board)
        break if end_conditions
      end
      result
      break unless play_again?
      reset
    end
    show_bye
  end

  private

  def setup(human)
    computer.assign_stats(human)
    board.display
  end

  def player_turn(order, board)
    if human.order == order
      human.place_symbol(board)
    else
      computer.place_symbol(board)
    end
    board.display_and_clear
  end

  def end_conditions
    board.winning_symbol || board.full?
  end

  def result
    if human.symbol == board.winning_symbol
      puts "You won!" 
    elsif computer.symbol == board.winning_symbol
      puts "You lost!"
    else
      puts "It's a tie." 
    end
  end

  def play_again?
    input = ""
    puts "Do you want to play again? Enter 'Y' for yes, 'N' for no."
    loop do
      input = gets.strip
      input = input.downcase
      break if %w(y yes n no).include?(input)
    end
    %w(y yes).include?(input)
  end

  def reset
    human.random_order
    computer.assign_order(human.order)
    board.reset
    board.display_and_clear
  end

  def show_bye
    puts "Thanks for playing!"
  end
end

Game.new.play
