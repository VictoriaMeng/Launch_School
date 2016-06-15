require "yaml"

HANDS = { %w(rock r) => "Rock",
          %w(paper p) => "Paper",
          %w(scissors sc) => "Scissors",
          %w(spock sp) => "Spock",
          %w(lizard l) => "Lizard" }.freeze

LOSING_HANDS = { "Rock" => %w(Scissors Lizard),
                 "Paper" => %w(Spock Rock),
                 "Scissors" => %w(Lizard Paper),
                 "Lizard" => %w(Spock Paper),
                 "Spock" => %w(Rock Scissors) }.freeze

class Player
  attr_accessor :wins, :name, :hands

  def show_past_hands
    puts "#{name}'s previous hands - #{hands}"
  end
end

class Human < Player
  attr_accessor :hands, :name

  def initialize
    @name = enter_name
    @wins = 0
    @hands = []
  end

  def enter_name
    input = ""
    puts "What's your a name?"
    loop do
      input = gets.strip
      break if !input.empty?
      puts "Please enter a name."
    end
    input
  end

  def validate_input
    input = ""
    loop do
      list_options
      input = gets.chomp
      break if HANDS.keys.flatten.include?(input.downcase)
      puts "#{input} isn't a valid hand."
    end
    input.downcase
  end

  def match_hand(input)
    HANDS.keys.each { |keys| hands << HANDS[keys] if keys.include?(input) }
    hands[-1]
  end

  def choose_hand
    input = validate_input
    match_hand(input)
  end

  def list_options
    HANDS.each { |keys, hand| puts "Enter '#{keys[1].upcase}' for #{hand}." }
  end

  def show_past_hands
    puts "#{name}'s previous hands - #{hands}"
  end

  def reset
    @hands = []
    @wins = 0
  end
end

class Computer < Player
  attr_accessor :hand_choices, :losing_hands

  ROBOTS = ["Glados", "R2D2", "Hal"].freeze

  def self.random_ai
    ai = ROBOTS.sample
    case ai
    when "Glados"
      Glados.new
    when "R2D2"
      R2D2.new
    when "Hal"
      Hal.new
    end
  end

  def show_name
    puts "This game, your opponent will be #{name}."
  end

  def choose_hand
    hands << @hand_choices.sample
  end

  def track_losing_hand
    losing_hands << hands[-1]
  end

  def analyze_losses(rounds)
    hands_to_avoid = []
    losing_hands.uniq.each do |hand|
      if (losing_hands.count(hand) / rounds) >= Game::LOSS_LIMIT
        hands_to_avoid << hand
      end
    end
    hands_to_avoid
  end

  def reset
    @wins = 0
  end
end

class R2D2 < Computer
  def initialize
    @name = "R2D2"
    @hands = []
    @wins = 0
    @losing_hands = []
    @hand_choices = %w(Rock)
  end

  def adjust_ai(hands_to_avoid)
    choices = []
    loop do
      choices = [HANDS.values.sample]
      break if !hands_to_avoid.include?(choices[0])
    end
    @hand_choices = choices
  end
end

class Hal < Computer
  def initialize
    @name = "Hal"
    @hands = []
    @wins = 0
    @losing_hands = []
    @hand_choices = %w(Scissors) * 5 + %w(Lizard Spock Lizard Spock Rock)
  end

  def adjust_ai(hands_to_avoid)
    choices = []
    loop do
      choices = [HANDS.values.sample]
      choices *= 5
      5.times { choices << HANDS.values.sample }
      break if choices.all? { |hand| !hands_to_avoid.include?(hand) }
    end
    @hand_choices = choices
  end
end

class Glados < Computer
  def initialize
    @name = "Glados"
    @hands = []
    @wins = 0
    @losing_hands = []
    @hand_choices = HANDS.values
  end

  def cheat(human_hand)
    computer_hand = ""
    loop do
      computer_hand = HANDS.values.sample
      break if LOSING_HANDS[computer_hand].include?(human_hand)
    end
    hands[-1] = computer_hand
  end
end

class Game
  WIN_REQUIREMENT = 10
  LOSS_LIMIT = 0.66

  attr_accessor :human, :computer, :rounds, :round_winners, :ties
  attr_reader :winner, :round_winner

  def initialize
    @human = Human.new
    @computer = Computer.random_ai
    @round_winners = []
    @ties = 0
    @rounds = 0
  end

  def clear_score
    @rounds = 0
    @round_winners = []
    @ties = 0
  end

  def show_intro
    puts <<~INTRO
      Welcome to Rock-Paper-Scissors-Lizard-Spock. \
Win #{WIN_REQUIREMENT} rounds to win the game!
    INTRO
  end

  def add_round
    @rounds += 1
  end

  def add_tie
    @ties += 1
  end

  def show_all_hands
    human.show_past_hands
    computer.show_past_hands
  end

  def play_round
    add_round
    human_hand = human.choose_hand
    computer.choose_hand
    computer.cheat(human_hand) if computer.name == "Glados"
    @round_winner = compare_hands
    adjust_score
    show_round_winner
    show_score
    show_all_hands
  end

  def compare_hands
    human_hand = human.hands[-1]
    computer_hand = computer.hands[-1]
    if human_hand == computer_hand
      "tie"
    elsif LOSING_HANDS[human_hand].include?(computer_hand)
      human.name
    else
      computer.name
    end
  end

  def adjust_score
    round_winners << round_winner
    case round_winner
    when "tie"
      add_tie
    when human.name
      human.wins += 1
    else
      computer.wins += 1
      computer.track_losing_hand
    end
  end

  def round_tie_message
    puts "You both picked #{human.hands[-1]}. It's a tie!"
  end

  def round_human_win_message
    puts <<~HUMAN_WIN
      #{human.name} picked #{human.hands[-1]}. \
#{computer.name} picked #{computer.hands[-1]}. \
You win!
    HUMAN_WIN
  end

  def round_computer_win_message
    puts <<~COMPUTER_WIN
#{human.name} picked #{human.hands[-1]}. \
#{computer.name} picked #{computer.hands[-1]}. \
You lose!
    COMPUTER_WIN
  end

  def show_round_winner
    case round_winner
    when "tie"
      round_tie_message
    when human.name
      round_human_win_message
    else
      round_computer_win_message
    end
  end

  def show_score
    puts <<~SCORE
      Score - #{human.name}: #{human.wins} - \
#{computer.name}: #{computer.wins} - \
Ties: #{ties}
    SCORE
  end

  def win_condition?
    human.wins == WIN_REQUIREMENT || computer.wins == WIN_REQUIREMENT
  end

  def set_winner
    @winner = human.name if human.wins == WIN_REQUIREMENT
    @winner = computer.name if computer.wins == WIN_REQUIREMENT
  end

  def show_winner
    puts <<~FINAL_SCORE
      #{human.name} won #{human.wins} rounds. \
#{computer.name} won #{computer.wins} rounds.
    FINAL_SCORE
    if winner == human.name
      puts "You win!"
    else
      puts "You lose!"
    end
  end

  def set_show_winner
    set_winner
    show_winner
  end

  def play_again?
    input = ""
    puts "Would you like to play again? - Enter 'Y' for yes, 'N' for no."
    loop do
      input = gets.chomp
      input = input.downcase
      break if %w(y yes n no).include?(input)
      puts "Please enter 'y' or 'n'."
    end
    %w(y yes).include?(input)
  end

  def reset
    @computer = Computer.random_ai
    clear_score
    human.reset
    computer.reset
  end

  def new_game_setup
    hands_to_avoid = computer.analyze_losses(rounds)
    reset
    computer.adjust_ai(hands_to_avoid) if computer.name != "Glados"
  end

  def show_bye
    puts "Thanks for playing!"
  end

  def play
    show_intro
    loop do
      computer.show_name
      loop do
        play_round
        break if win_condition?
      end
      set_show_winner
      break if !play_again?
      new_game_setup
    end
    show_bye
  end
end

Game.new.play
