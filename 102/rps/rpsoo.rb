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
  attr_accessor :wins

  def initialize
    @wins = 0
  end
end

class Human < Player
  attr_accessor :hands, :name

  def setup
    clear_hands
    enter_name
  end

  def clear_hands
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
    @name = input
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
    clear_hands
    @wins = 0
  end
end

class Computer < Player
  ROBOTS = ["Glados", "R2D2", "Hal"].freeze

  attr_accessor :ai

  def random_ai
    ai = ROBOTS.sample
    case ai
    when "Glados"
      @ai = Glados.new
    when "R2D2"
      @ai = R2D2.new
    when "Hal"
      @ai = Hal.new
    end
    show_name
  end

  def show_name
    puts "This round, your opponent is #{ai.name}."
  end

  def show_past_hands
    puts "#{ai.name}'s previous hands - #{ai.hands}"
  end

  def reset
    @wins = 0
  end
end

class AI
  attr_accessor :name, :hands, :hand_choices

  @@hands_to_avoid = []

  def self.hands_to_avoid
    @@hands_to_avoid
  end

  def analyze_losses(human_name)
    @@hands_to_avoid = []
    computer_losses = []

    Round.winners.each_with_index do |winner, index|
      computer_losses << hands[index] if winner == human_name
    end

    computer_losses.uniq.each do |hand|
      if (computer_losses.count(hand) / Round.rounds) >= Game::LOSS_LIMIT
        @@hands_to_avoid << hand
      end
    end
  end

  def choose_hand
    hands << @hand_choices.sample
  end
end

class R2D2 < AI
  def initialize
    @name = "R2D2"
    @hands = []
    @hand_choices = adjust_ai
  end

  def adjust_ai
    hta = AI.hands_to_avoid
    choices = []
    loop do
      choices = [HANDS.values.sample]
      break if !hta.include?(choices[0])
    end
    choices
  end
end

class Hal < AI
  def initialize
    @name = "Hal"
    @hands = []
    @hand_choices = adjust_ai
  end

  def adjust_ai
    hta = AI.hands_to_avoid
    choices = []
    loop do
      choices = [HANDS.values.sample]
      choices *= 5
      5.times { choices << HANDS.values.sample }
      break if choices.all? { |hand| !hta.include?(hand) }
    end
    choices
  end
end

class Glados < AI
  def initialize
    @name = "Glados"
    @hands = []
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

class Round
  attr_accessor :winner

  @@rounds = 0
  @@ties = 0
  @@winners = []

  def initialize
    @@rounds += 1
    @winner = nil
  end

  def self.add_tie
    @@ties += 1
  end

  def self.rounds
    @@rounds
  end

  def self.ties
    @@ties
  end

  def self.winners
    @@winners
  end

  def self.reset
    @@rounds = 0
    @@ties = 0
    @@winners = []
  end
end

class Game
  WIN_REQUIREMENT = 10
  LOSS_LIMIT = 0.66

  attr_accessor :human, :computer, :round
  attr_reader :winner

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def setup
    show_intro
    human.setup
  end

  def show_intro
    puts <<~INTRO
      Welcome to Rock-Paper-Scissors-Lizard-Spock. \
Win #{WIN_REQUIREMENT} rounds to win the game!
    INTRO
  end

  def play_round
    ai = computer.ai
    @round = Round.new
    ai.choose_hand
    human_hand = human.choose_hand
    ai.cheat(human_hand) if ai.name == "Glados"
    compare_hands
    adjust_score
    show_round_winner
    show_score
    human.show_past_hands
    computer.show_past_hands
  end

  def compare_hands
    human_hand = human.hands[-1]
    computer_hand = computer.ai.hands[-1]
    round.winner = case
                   when human_hand == computer_hand
                     "tie"
                   when LOSING_HANDS[human_hand].include?(computer_hand)
                     human.name
                   else
                     computer.ai.name
                   end
  end

  def adjust_score
    Round.winners << round.winner
    case round.winner
    when "tie"
      Round.add_tie
    when human.name
      human.wins += 1
    else
      computer.wins += 1
    end
  end

  def round_tie_message
    puts "You both picked #{human.hands[-1]}. It's a tie!"
  end

  def round_human_win_message
    puts <<~HUMAN_WIN
      #{human.name} picked #{human.hands[-1]}. \
#{computer.ai.name} picked #{computer.ai.hands[-1]}. \
You win!
    HUMAN_WIN
  end

  def round_computer_win_message
    puts <<~COMPUTER_WIN
#{human.name} picked #{human.hands[-1]}. \
#{computer.ai.name} picked #{computer.ai.hands[-1]}. \
You lose!
    COMPUTER_WIN
  end

  def show_round_winner
    case round.winner
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
#{computer.ai.name}: #{computer.wins} - \
Ties: #{Round.ties}
    SCORE
  end

  def win_condition?
    human.wins == WIN_REQUIREMENT || computer.wins == WIN_REQUIREMENT
  end

  def set_winner
    @winner = case
              when human.wins == WIN_REQUIREMENT
                human.name
              when computer.ai.name == WIN_REQUIREMENT
                computer.ai.name
              end
  end

  def show_winner
    puts <<~FINAL_SCORE
      #{human.name} won #{human.wins} rounds. \
#{computer.ai.name} won #{computer.wins} rounds.
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
    human.reset
    computer.reset
    Round.reset
  end

  def show_bye
    puts "Thanks for playing!"
  end

  def play
    setup
    loop do
      computer.random_ai
      loop do
        play_round
        break if win_condition?
      end
      set_show_winner
      break if !play_again?
      computer.ai.analyze_losses(human.name)
      reset
    end
    show_bye
  end
end

Game.new.play
