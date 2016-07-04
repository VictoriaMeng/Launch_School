class Board
  ROWS = [[1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
          [1, 4, 7],
          [2, 5, 8],
          [3, 6, 9],
          [1, 5, 9],
          [3, 5, 7]].map { |row| row.map(&:to_s) }.freeze

  attr_accessor :squares

  def initialize
    @squares = {}
    reset
  end

  def reset
    ("1".."9").to_a.each { |number| squares[number] = Square.new(number) }
  end

  def display
    puts "       |       |      "
    puts "   #{squares['1']}   |   #{squares['2']}   |   #{squares['3']}   "
    puts "       |       |      "
    puts "----------------------"
    puts "       |       |      "
    puts "   #{squares['4']}   |   #{squares['5']}   |   #{squares['6']}   "
    puts "       |       |      "
    puts "----------------------"
    puts "       |       |      "
    puts "   #{squares['7']}   |   #{squares['8']}   |   #{squares['9']}   "
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

  def join_or(squares, delimiter=", ", word="or")
    squares[-1] = "#{word} #{squares.last}" if squares.size > 1
    squares.join(delimiter)
  end

  def show_blank_squares
    puts "Empty squares: #{join_or(blank_squares)}"
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
    Square.valid?(symbol)
  end
end

class Player
  attr_accessor :symbol, :name, :wins

  def initialize
    @wins = 0
  end

  def score_text
    "#{name}: #{wins}"
  end

  def reset
    @wins = 0
  end
end

class Human < Player
  def initialize
    super
    @name = enter_name
    @symbol = pick_symbol
  end

  def enter_name
    input = ""
    puts "Enter your name."
    loop do
      input = gets.strip
      break unless input.empty?
      puts "Please enter a name."
    end
    input
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
      empty = board.blank_squares.include?(input)
      break if valid && empty
      puts "#{input} isn't a valid square." unless valid
      puts "#{input} is full." if valid && !empty
    end
    board[input] = symbol
  end
end

class Computer < Player
  def initialize
    super
    @name = "Computer"
  end

  def assign_symbol(human_symbol)
    @symbol = "O" if human_symbol == "X"
    @symbol = "X" if human_symbol == "O"
  end

  def human_symbol
    return "X" if symbol == "O"
    return "O" if symbol == "X"
  end

  def place_symbol(board)
    if board.two_in_row(symbol)
      completing_row(board, symbol)
    elsif board.two_in_row(human_symbol)
      completing_row(board, human_symbol)
    elsif board.squares["5"].empty?
      fill_center_square(board)
    else
      fill_random_square(board)
    end
  end

  def fill_center_square(board)
    board["5"] = symbol
    print_move("5")
  end

  def completing_row(board, marker)
    winning_square = board.two_in_row(marker)
    board[winning_square] = symbol
    print_move(winning_square)
  end

  def fill_random_square(board)
    square = board.blank_squares.sample
    board[square] = symbol
    print_move(square)
  end

  def print_move(square)
    puts "#{name} picked #{square}"
  end
end

class Game
  WIN_REQUIREMENT = 5

  attr_accessor :board, :player_1, :player_2, :ties, :human, :computer, :current_player

  def initialize
    @board = Board.new
    @human = Human.new
    @computer = Computer.new
    @ties = 0
  end

  def play
    setup
    loop do
      play_match until winner
      announce_winner
      break unless play_again?
      reset
    end
    show_bye
  end

  private

  def random_order
    human_order = [1, 2].sample
    @current_player = @human if human_order == 1
    @current_player = @computer if human_order == 2
  end

  def current_player?(player)
    current_player == player
  end

  def switch_player
    return @current_player = @computer if current_player?(human)
    @current_player = @human
  end

  def setup
    computer.assign_symbol(human.symbol)
    random_order
    board.display
  end

  def play_match
    play_turn(board) until match_end_conditions
    match_result
    pause_between_match unless winner
  end

  def show_score
    puts "Score - #{human.score_text} - #{computer.score_text} - Ties: #{ties}"
  end

  def play_turn(board)
    human.place_symbol(board) if current_player?(human)
    computer.place_symbol(board) if current_player?(computer)
    board.display_and_clear
    switch_player
  end

  def match_end_conditions
    board.winning_symbol || board.full?
  end

  def match_result
    if human.symbol == board.winning_symbol
      human_match_win
    elsif computer.symbol == board.winning_symbol
      computer_match_win
    else
      tie
    end
    show_score
  end

  def human_match_win
    human.wins += 1
    puts "You won the match!"
  end

  def computer_match_win
    computer.wins += 1
    puts "You lost the match!"
  end

  def tie
    @ties += 1
    puts "This match is a tie!"
  end

  def pause_between_match
    show_current_lead
    gets.chomp
    reset_match
  end

  def show_current_lead
    lead = current_lead
    puts "You are currently tied - #{next_match_prompt}" if lead == "tie"
    puts "#{lead} is in the lead. - #{next_match_prompt}" if lead != "tie"
  end

  def current_lead
    if human.wins == computer.wins
      "tie"
    else
      human.wins > computer.wins ? human.name : computer.name
    end
  end

  def next_match_prompt
    "Hit 'enter' to move onto the next match."
  end

  def reset_match
    random_order
    board.reset
    board.display_and_clear
  end

  def winner
    return human if human.wins == WIN_REQUIREMENT
    return computer if computer.wins == WIN_REQUIREMENT
  end

  def human_win_text
    "#{human.name} won #{WIN_REQUIREMENT} rounds. - You win!"
  end

  def computer_win_text
    "#{computer.name} won #{WIN_REQUIREMENT} rounds. - You lost!"
  end

  def announce_winner
    puts human_win_text if winner == human
    puts computer_win_text if winner == computer
  end

  def play_again?
    input = ""
    puts "Do you want to play again? Enter 'Y' for yes, 'N' for no."
    loop do
      input = gets.strip
      input = input.downcase
      break if %w(y yes n no).include?(input)
      puts "Please enter 'y' for yes, 'n' for no."
    end
    %w(y yes).include?(input)
  end

  def reset
    human.reset
    computer.reset
    board.reset
    board.display_and_clear
  end

  def show_bye
    puts "Thanks for playing!"
  end
end

Game.new.play
