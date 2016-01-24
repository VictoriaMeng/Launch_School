require "yaml"
MESSAGES = YAML.load_file("ttt_msgs.yml")
lang = "en"

WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]

def prompt(lang, category, message)
  puts "--> " + MESSAGES[lang][category][message]
end

def say(message)
  puts "--> #{message}"
end

def draw_board(board)
  system "clear"
  puts "       |       |      "
  puts "   #{board[1]}   |   #{board[2]}   |   #{board[3]}   "
  puts "       |       |      "
  puts "----------------------"
  puts "       |       |      "
  puts "   #{board[4]}   |   #{board[5]}   |   #{board[6]}   "
  puts "       |       |      "
  puts "----------------------"
  puts "       |       |      "
  puts "   #{board[7]}   |   #{board[8]}   |   #{board[9]}   "
  puts "       |       |      "
end

def starting_board
  board = {}
  (1..9).each { |square| board[square] = " " }
  board
end

def assign_symbols(symbols, lang, category)
  begin
    prompt(lang, category, "enter_symbol")
    input = gets.chomp
  end until input.downcase == "x" || input.downcase == "o"

  symbols[:human] = input.upcase
  symbols[:computer] = "X" if symbols[:human] == "O"
  symbols[:computer] = "O" if symbols[:human] == "X"
end

def print_human_first(messages, player)
  say <<-RANDOMIZING.chomp + <<-HUMAN_FIRST if player == "human"
#{messages["randomize_turns"]}
    RANDOMIZING
#{messages["human_first"]}
    HUMAN_FIRST
end

def print_computer_first(board, symbol, messages)
  if board.values.count(symbol) == 1 && board.values.count(" ") == 8
    say <<-RANDOMIZING.chomp + <<-COMPUTER_FIRST
#{messages["randomize_turns"]}
      RANDOMIZING
#{messages["computer_first"]}
      COMPUTER_FIRST
  end
end

def turn_order
  order = {}
  players = ["human", "computer"]
  order[:player_1] = players.shuffle!.pop
  order[:player_2] = players.pop
  order
end

def squares_blank(board)
  board.keys.select { |square, symbol| square if board[square] == " " }
end

def join_or(squares, delimiter=", ", word="or")
  squares[-1] = "#{word} #{squares.last}" if squares.size > 1
  squares.join(delimiter)
end

def pick_square_human(board, symbol, messages)
  say "#{messages["enter_square"]} #{join_or(squares_blank(board))}"
  begin
    square = gets.chomp
    if !(1..9).include?(square.to_i)
      say "#{messages["error_square_invalid"]} #{join_or(squares_blank(board))}"
    elsif board[square.to_i] != " "
      say "#{messages["error_square_blocked"]} #{join_or(squares_blank(board))}"
    end
  end until board[square.to_i] == " "
  board[square.to_i] = symbol
  square
end

def turn_human(board, symbol, messages)
  square = pick_square_human(board, symbol, messages)
  draw_board(board)
  say <<-SYMBOL.chomp + <<-SQUARE
#{messages["you_placed"]} #{symbol} 
    SYMBOL
#{messages["in_square"]} #{square}.
    SQUARE
end

def two_in_row?(board, symbol)
  WINNING_LINES.each do |line|
    if board.values_at(*line).count(symbol) == 2
      line.each { |square| return square if board[square] == " " }
    end
  end
  nil
end

def pick_square_computer(board, symbols)
  if two_in_row?(board, symbols[:computer])
    square = two_in_row?(board, symbols[:computer])
  elsif two_in_row?(board, symbols[:human])
    square = two_in_row?(board, symbols[:human])
  elsif board[5] == " "
    square = 5
  else
    square = squares_blank(board).sample
  end
  board[square] = symbols[:computer]
  square
end

def turn_computer(board, symbols, messages)
  square = pick_square_computer(board, symbols)
  draw_board(board)
  print_computer_first(board, symbols[:computer], messages["turn_order"])
  say <<-SYMBOL.chomp + <<-SQUARE
#{messages["turn_computer"]["computer_placed"]} #{symbols[:computer]} 
    SYMBOL
#{messages["turn_computer"]["in_square"]} #{square}.
    SQUARE
end

def turn(board, symbols, messages, player)
  turn_human(board, symbols[:human], messages["turn_human"]) if player == "human"
  turn_computer(board, symbols, messages) if player == "computer"
end

def three_in_row?(board, symbols)
  WINNING_LINES.each do |line|
    return "human" if board.values_at(*line).count(symbols[:human]) == 3
    return "computer" if board.values_at(*line).count(symbols[:computer]) == 3
  end
  nil
end

def round_end?(board, symbols)
  three_in_row?(board, symbols) || !board.value?(" ")
end

def result_round(board, symbols, score, lang, category)
  if three_in_row?(board, symbols) == "human"
    prompt(lang, category, "win")
    score[:wins] += 1
  elsif three_in_row?(board, symbols) == "computer"
    prompt(lang, category, "loss")
    score[:losses] += 1
  else
    prompt(lang, category, "tie")
    score[:ties] += 1
  end
end

def print_score(score, messages)
  say <<-WINS.chomp + <<-LOSSES.chomp + <<-TIES
#{messages["wins"]} #{score[:wins]} - 
    WINS
#{messages["losses"]} #{score[:losses]} - 
    LOSSES
#{messages["ties"]} #{score[:ties]}
    TIES
end

def result_game(score, lang, category)
  prompt(lang, category, "win") if score[:wins] == 5
  prompt(lang, category, "loss") if score[:losses] == 5
end

def play_again?(lang, category)
  begin
    prompt(lang, category, "play_again")
    again = gets.chomp
  end until again.downcase == "y" || again.downcase == "n"
  again.downcase
end

def next_round?(lang, category)
  prompt(lang, category, "next_round")
  gets.chomp
end

loop do
  score = {  wins: 0,
             losses: 0,
             ties: 0
          }

  symbols = {}

  prompt(lang, "hi_bye", "welcome")
  assign_symbols(symbols, lang, "symbols")

  loop do
    board = starting_board
    order = turn_order
    draw_board(board) if order[:player_1] == "human"
    print_human_first(MESSAGES[lang]["turn_order"], order[:player_1])
    
    until round_end?(board, symbols)
      turn(board, symbols, MESSAGES[lang], order[:player_1])
      break if round_end?(board, symbols)
      turn(board, symbols, MESSAGES[lang], order[:player_2])
    end

    result_round(board, symbols, score, lang, "results_round")
    print_score(score, MESSAGES[lang]["score"])

    break if score[:wins] == 5 || score[:losses] == 5
    next_round?(lang, "results_round")
  end

    result_game(score, lang, "results_game") 
    break if play_again?(lang, "hi_bye") == "n"
end

prompt(lang, "hi_bye", "thanks")
