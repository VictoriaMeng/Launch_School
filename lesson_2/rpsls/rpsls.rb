require "yaml"
lang = "en"
MESSAGES = YAML.load_file("rpsls_messages.yml")

HAND_LIST = { 1 => "Rock",
              2 => "Paper",
              3 => "Scissors",
              4 => "Lizard",
              5 => "Spock"
            }

WINNING_HANDS = {  "Rock" => %w(Scissors Lizard),
                   "Paper" => %w(Rock Spock),
                   "Scissors" => %w(Paper Lizard),
                   "Lizard" => %w(Spock Paper),
                   "Spock" => %w(Spock Paper)
                }

HAND_COMBO_MESSAGES = {  %w(Rock Scissors) => MESSAGES[lang]["rock_scissors"],
                         %w(Lizard Rock) => MESSAGES[lang]["rock_lizard"],
                         %w(Paper Rock) => MESSAGES[lang]["paper_rock"],
                         %w(Paper Spock) => MESSAGES[lang]["paper_spock"],
                         %w(Paper Scissors) => MESSAGES[lang]["scissors_paper"],
                         %w(Lizard Scissors) => MESSAGES[lang]["scissors_lizard"],
                         %w(Lizard Spock) => MESSAGES[lang]["lizard_spock"],
                         %w(Lizard Paper) => MESSAGES[lang]["lizard_paper"],
                         %w(Rock Spock) => MESSAGES[lang]["spock_rock"],
                         %w(Scissors Spock) => MESSAGES[lang]["spock_scissors"]
                                                                                  }

def prompt(lang, message)
  puts "--> " + MESSAGES[lang][message]
end

def print_tally(tally)
  puts "--> Your Wins: #{tally[:wins]} - Computer Wins: #{tally[:losses]} - Ties: #{tally[:ties]}"
end

def valid_hand?(input, list)
  list.value?(input.capitalize) || (1..5).include?(input.to_i)
end

def convert_hand_input(input, list)
  return input.capitalize if list.value?(input.capitalize)
  return list[input.to_i] if (1..5).include?(input.to_i)
end

def round_result(hands, tally, wins)
  if hands[:human] == hands[:computer]
    tally[:ties] += 1
    "It's a tie!"
  elsif wins[hands[:human]].include?(hands[:computer])
    tally[:wins] += 1
    "You win!"
  else
    tally[:losses] += 1
    "You lose!"
  end
end

def round_action(hands, combo_messages)
  hands = [hands[:human], hands[:computer]].sort
  combo_messages[hands]
end

def print_round_summary(round)
  puts "--> You pick #{round[:hands][:human]}. Computer picks #{round[:hands][:computer]}."
  puts "--> #{round[:action]} #{round[:result]}" if round[:result] != "It's a tie!"
  puts "--> #{round[:result]}" if round[:result] == "It's a tie!"
end

def print_final_winner(tally)
  puts "You win 5 rounds! You win!" if tally[:wins] == 5
  puts "Computer wins 5 rounds! You lose!" if tally[:losses] == 5
end

def yes_no(play_again)
  return "yes" if play_again == "y".downcase || play_again == "yes".downcase
  return "no" if play_again == "n".downcase || play_again == "no".downcase
end

loop do
  tally_human = {  wins: 0,
                   losses: 0,
                   ties: 0
                }

  round = { hands: {},
          }

  prompt(lang, "welcome")

  until tally_human[:wins] == 5 || tally_human[:losses] == 5
    print_tally(tally_human)

    begin
      prompt(lang, "enter_hand")
      hand_input = gets.chomp
      round[:hands][:human] = convert_hand_input(hand_input, HAND_LIST)
    end until valid_hand?(hand_input, HAND_LIST)

    round[:hands][:computer] = HAND_LIST[(1..5).to_a.sample]

    round[:action] = round_action(round[:hands], lang, HAND_COMBO_MESSAGES)
    round[:result] = round_result(round[:hands], tally_human, WINNING_HANDS)

    print_round_summary(round)
  end

  print_final_winner(tally_human)

  begin
    prompt(lang, "play_again?")
    play_again = gets.chomp
  end until yes_no(play_again)
  break if yes_no(play_again) == "no"
end

prompt(lang, "thanks")
