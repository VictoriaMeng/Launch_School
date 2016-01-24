require "yaml"
MESSAGES = YAML.load_file("ttt_msgs.yml")
lang = "en"

WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]

def say(message)
  puts "--> #{message}"
end

def prompt(lang, category, message)
  say MESSAGES[lang][category][message]
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
    symbol = input.upcase
  end until %w(X O).include?(symbol)

  symbols[:human] = symbol
  symbols[:computer] = case symbols[:human]
                       when "O" then "X"
                       when "X" then "O"
                       end
end

def print_human_first(messages, player)
  say <<~HUMAN_FIRST if player == "human"
    #{messages["randomize_turns"]} \
    #{messages["human_first"]}
  HUMAN_FIRST
end

def print_computer_first(board, symbol, messages)
  if board.values.count(symbol) == 1 && board.values.count(" ") == 8
    say <<~COMPUTER_FIRST
      #{messages["randomize_turns"]} \
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
    input = gets.chomp
    square = input.to_i
    if !(1..9).include?(square)
      say "#{messages["error_square_invalid"]} #{join_or(squares_blank(board))}"
    elsif board[square] != " "
      say "#{messages["error_square_blocked"]} #{join_or(squares_blank(board))}"
    end
  end until board[square] == " "
  square
end

def turn_human(board, symbol, messages)
  square = pick_square_human(board, symbol, messages)
  board[square] = symbol
  draw_board(board)
  say <<~SQUARE
    #{messages["you_placed"]} #{symbol} \
    #{messages["in_square"]} #{square}.
  SQUARE
end

def two_in_row(board, symbol)
  WINNING_LINES.each do |line|
    if board.values_at(*line).count(symbol) == 2
      line.each { |square| return square if board[square] == " " }
    end
  end
  nil
end

def pick_square_computer(board, symbols)
  if two_in_row(board, symbols[:computer])
    two_in_row(board, symbols[:computer])
  elsif two_in_row(board, symbols[:human])
    two_in_row(board, symbols[:human])
  elsif board[5] == " "
    5
  else
    squares_blank(board).sample
  end
end

def turn_computer(board, symbols, messages)
  square = pick_square_computer(board, symbols)
  board[square] = symbols[:computer]
  draw_board(board)
  print_computer_first(board, symbols[:computer], messages["turn_order"])
  say <<~SQUARE
    #{messages["turn_computer"]["computer_placed"]} #{symbols[:computer]} \
    #{messages["turn_computer"]["in_square"]} #{square}.
  SQUARE
end

def turn(round, symbols, messages, player)
  turn_human(round[:board], symbols[:human], messages["turn_human"]) if round[:order][player] == "human"
  turn_computer(round[:board], symbols, messages) if round[:order][player] == "computer"
end

def three_in_row(board, symbols)
  WINNING_LINES.each do |line|
    return "human" if board.values_at(*line).count(symbols[:human]) == 3
    return "computer" if board.values_at(*line).count(symbols[:computer]) == 3
  end
  nil
end

def round_end?(board, symbols)
  three_in_row(board, symbols) || !board.value?(" ")
end

def result_round(board, game, lang, category)
  if three_in_row(board, game[:symbols]) == "human"
    prompt(lang, category, "win")
    game[:score][:wins] += 1
  elsif three_in_row(board, game[:symbols]) == "computer"
    prompt(lang, category, "loss")
    game[:score][:losses] += 1
  else
    prompt(lang, category, "tie")
    game[:score][:ties] += 1
  end
end

def print_score(score, messages)
  say <<~SCORE
    #{messages["wins"]} #{score[:wins]} - \
    #{messages["losses"]} #{score[:losses]} - \
    #{messages["ties"]} #{score[:ties]}
  SCORE
end

def five_wins?(score)
  score[:wins] == 5 || score[:losses] == 5
end

def result_game(score, lang, category)
  prompt(lang, category, "win") if score[:wins] == 5
  prompt(lang, category, "loss") if score[:losses] == 5
end

def play_again?(lang, category)
  begin
    prompt(lang, category, "play_again")
    input = gets.chomp
    again = input.downcase
  end until %w(y yes n no).include?(again)
  %w(y yes).include?(again)
end

def next_round?(lang, category)
  prompt(lang, category, "next_round")
  gets.chomp
end

loop do
  game = {  score: { wins: 0,
                      losses: 0,
                      ties: 0
                      },
            symbols: {}
         }

  prompt(lang, "hi_bye", "welcome")
  assign_symbols(game[:symbols], lang, "symbols")

  loop do
    round = {}
    round[:board] = starting_board
    round[:order] = turn_order
    draw_board(round[:board]) if round[:order][:player_1] == "human"
    print_human_first(round[:order][:player_1], MESSAGES[lang]["turn_order"])
    
    until round_end?(round[:board], game[:symbols])
      turn(round, game[:symbols], MESSAGES[lang], :player_1)
      break if round_end?(round[:board], game[:symbols])
      turn(round, game[:symbols], MESSAGES[lang], :player_2)
    end

    result_round(round[:board], game, lang, "results_round")
    print_score(game[:score], MESSAGES[lang]["score"])

    break if five_wins?(game[:score])
    next_round?(lang, "results_round")
  end

  result_game(game[:score], lang, "results_game") 
  break unless play_again?(lang, "hi_bye")
end

prompt(lang, "hi_bye", "thanks")
