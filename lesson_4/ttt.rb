require "yaml"
MESSAGES = YAML.load_file("ttt_msgs.yml")
lang = "en"

def prompt(lang, message)
  puts "--> " + MESSAGES[lang][message]
end

def say(message)
  puts "--> #{message}"
end

def starting_board
  board = {}
  (1..9).each {|square| board[square] = " "}
  board
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

def all_squares_empty?(board)
  board.each {|square, symbol| square == " "}
end

def assign_symbols(symbols, lang, instruct, error)
  prompt(lang, instruct)
  input = gets.chomp

  until input.downcase == "x" || input.downcase == "o"
    prompt(lang, error)
    input = gets.chomp
  end

  symbols[:human] = input.upcase
  symbols[:computer] = "X" if symbols[:human] == "O"
  symbols[:computer] = "O" if symbols[:human] == "X"
end

def print_symbols(lang, message_1, message_2, symbols)
  say <<-SYMBOL_HUMAN.chomp + <<-SYMBOL_COMPUTER
  #{MESSAGES[lang][message_1]} #{symbols[:human]}. 
    SYMBOL_HUMAN
  #{MESSAGES[lang][message_2]} #{symbols[:computer]}.
    SYMBOL_COMPUTER
end

def randomize_first_player
  players = ["human", "computer"]
  player_1 = players.sample
end

def print_first_player(lang, player_1, randomize_turns, human_first, computer_first)
  say <<-RANDOMIZING.chomp + <<-FIRST_PLAYER
  #{MESSAGES[lang][randomize_turns]} 
    RANDOMIZING
  #{MESSAGES[lang][human_first]} if player_1 == "human"
  #{MESSAGES[lang][computer_first]} if player_1 == "computer"
    FIRST_PLAYER
end

score = {
          wins: 0,
          losses: 0,
          ties: 0
        }

symbols = {}

prompt(lang, "welcome")

assign_symbols(symbols, lang, "enter_symbol", "error_symbol_invalid")

board = starting_board
draw_board(board)
print_symbols(lang, "you_are", "opponent_is", symbols) if all_squares_empty?(board)
player_1 = randomize_first_player
print_first_player(lang, player_1, "randomize_turns", "human_first", "computer_first")



