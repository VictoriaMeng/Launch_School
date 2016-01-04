require "yaml"
lang = "en"
MESSAGES = YAML.load_file("rpsls_messages.yml")

HAND_LIST = {
              1 => "Rock", 
              2 => "Paper", 
              3 => "Scissors", 
              4 => "Lizard", 
              5 => "Spock"
                                }
WINS = {
          "Rock" => ["Scissors", "Lizard"],
          "Paper" => ["Rock", "Spock"],
          "Scissors" => ["Paper", "Lizard"],
          "Lizard" => ["Spock", "Paper"],
          "Spock" => ["Rock", "Scissors"],
                                              }

def prompt(lang, message)
  puts "--> " + MESSAGES[lang][message]
end

def print_tally(players)
  puts "--> Your Wins: #{players[:human][:wins]} - Computer Wins: #{players[:computer][:wins]}"
end

def check_hand(input, list)
  list.has_value?(input.capitalize) || (1..5).include?(input.to_i)
end

def convert_hand(input, list)
  return input.capitalize if list.has_value?(input.capitalize)
  return list[input.to_i] if (1..5).include?(input.to_i) 
end

def compare_hands(players, wins)
  human = players[:human][:hand]
  computer = players[:computer][:hand]

  if human == computer
    "It's a tie!"
  elsif wins[human].include?(computer)
    players[:human][:wins] += 1
    "You win!"
  else
    players[:computer][:wins] += 1
    "You lose!"
  end
end

def print_round_winner(players, result)
  human = players[:human][:hand]
  computer = players[:computer][:hand]

  puts "--> You pick #{human}. Computer picks #{computer}."

  puts "--> #{human} beats #{computer}. #{result}" if result == "You win!"
  puts "--> #{computer} beats #{human}. #{result}" if result == "You lose!"
  puts "--> #{result}" if result == "It's a tie!"
end

def print_final_winner(players)
  puts "You win 5 rounds! You win!" if players[:human][:wins] == 5
  puts "Computer wins 5 rounds! You lose!" if players[:computer][:wins] == 5
end

def yes_no(play_again)
  return "yes" if play_again == "y".downcase || play_again == "yes".downcase
  return "no" if play_again == "n".downcase || play_again == "no".downcase
end

loop do
  players = {
            human: {wins: 0},
            computer: {wins: 0}
            }

  prompt(lang, "welcome")

  until players[:human][:wins] == 5 || players[:computer][:wins] == 5
    print_tally(players)

    begin
      prompt(lang, "enter_hand")
      input = gets.chomp
      players[:human][:hand] = convert_hand(input, HAND_LIST)
    end until players[:human][:hand]

    players[:computer][:hand] = HAND_LIST[(1..5).to_a.sample]

    round_result = compare_hands(players, WINS)

    print_round_winner(players, round_result)
  end

  print_final_winner(players)

  begin
    prompt(lang, "play_again?")
    play_again = gets.chomp
  end until yes_no(play_again)
  break if yes_no(play_again) == "no"
end

prompt(lang, "thanks")











