require "yaml"

HANDS = { %w(rock r) => "Rock", %w(paper p) => "Paper", %w(scissors sc) => "Scissors", %w(spock sp) => "Spock", %w(lizard l) => "Lizard" }.freeze

LOSING_HANDS = { "Rock" => %w(Scissors Lizard), "Paper" => %w(Spock Rock), "Scissors" => %w(Lizard Paper), "Lizard" => %w(Spock Paper), "Spock" => %w(Rock Scissors) }.freeze

class Player
  attr_accessor :wins, :hands

  def show_past_hands
    puts "#{name}'s previous hands - #{hands}"
  end
end

class Human < Player
  attr_reader :name

  def initialize(name)
    @name = name
    @wins = 0
    @hands = []
  end

  def self.enter_name
    puts "What's your name?"
    name = gets.chomp
    loop do
      break if !name.empty?
      puts "Please enter a name."
      name = gets.chomp
    end
    name
  end

  def validate_input
    list_options
    input = gets.chomp
    loop do
      input = input.downcase
      break if HANDS.keys.flatten.include?(input)
      puts "#{input} isn't a valid hand."
      list_options
      input = gets.chomp
    end
    input
  end

  def match_hand(input)
    HANDS.keys.each { |keys| hands << HANDS[keys] if keys.include?(input) }
  end

  def choose_hand
    input = validate_input
    match_hand(input)
  end

  def list_options
    HANDS.each { |keys, hand| puts "Enter '#{keys[1].upcase}' for #{hand}." }
  end

  def reset
    @hands = []
    @wins = 0
  end
end

class Computer < Player
  ROBOTS = ["Glados", "R2D2", "Hal"].freeze

  attr_accessor :name, :bad_hands

  def initialize
    @name = ROBOTS.sample
    @wins = 0
    @hands = []
    @bad_hands = []
    hand_choices
  end

  def show_name
    puts "This round, your opponent is #{name}."
  end

  def hand_choices
    @hand_choices = %w(Rock) if name == "R2D2"
    @hand_choices = %w(Scissors) * 5 + %w(Rock Lizard Spock Lizard Spock) if name == "Hal"
    @hand_choices = HANDS.values if name == "Glados"
  end

  def choose_hand
    hands << @hand_choices.sample
  end

  def adjust_ai
    main_hand = ""
    loop do
      main_hand = HANDS.values.sample
      break if !bad_hands.include?(main_hand)
    end
    @hand_choices = [main_hand]
    if name == "Hal"
      @hand_choices *= 5
      4.times { @hand_choices << HANDS.values.sample }
    end
  end

  def reset
    @hands = []
    @wins = 0
    @name = Computer::ROBOTS.sample
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
    @human = Human.new(Human.enter_name)
    @computer = Computer.new
  end

  def show_intro
    puts "Let's play Rock-Paper-Scissors-Lizard-Spock. Win 10 rounds to win the game!"
  end

  def play_round
    @round = Round.new
    computer.choose_hand
    human.choose_hand
    cheat if computer.name == "Glados"
    compare_hands
    adjust_score
    show_round_winner
    show_score
    human.show_past_hands
    computer.show_past_hands
  end

  def cheat
    loop do
      computer.hands[-1] = HANDS.values.sample
      break if LOSING_HANDS[computer.hands[-1]].include?(human.hands[-1])
    end
  end

  def compare_hands
    round.winner = "tie" if human.hands[-1] == computer.hands[-1]
    round.winner = human.name if LOSING_HANDS[human.hands[-1]].include?(computer.hands[-1])
    round.winner = computer.name if LOSING_HANDS[computer.hands[-1]].include?(computer.hands[-1])
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

  def show_round_winner
    case round.winner
    when "tie"
      puts "You both picked #{human.hands[-1]}. It's a tie!"
    when human.name
      puts "#{human.name} picked #{human.hands[-1]}. #{computer.name} picked #{computer.hands[-1]}. You win!"
    else
      puts "#{human.name} picked #{human.hands[-1]}. #{computer.name} picked #{computer.hands[-1]}. You lose!"
    end
  end

  def show_score
    puts "Score - #{human.name}: #{human.wins} - #{computer.name}: #{computer.wins} - Ties: #{Round.ties}"
  end

  def win_condition?
    human.wins == WIN_REQUIREMENT || computer.wins == WIN_REQUIREMENT
  end

  def set_winner
    @winner = human.name if human.wins == WIN_REQUIREMENT
    @winner = computer.name if computer.wins == WIN_REQUIREMENT
  end

  def show_winner
    puts "#{human.name} won #{human.wins} rounds. #{computer.name} won #{computer.wins} rounds. "
    case winner
    when human.name
      puts "You win!"
    else
      puts "You lose!"
    end
  end

  def play_again?
    puts "Would you like to play again? - Enter 'Y' for yes, 'N' for no."
    input = gets.chomp
    loop do
      input = input.downcase
      break if %w(y yes n no).include?(input)
      puts "Please enter 'y' or 'n'."
      input = gets.chomp
    end
    %w(y yes).include?(input)
  end

  def reset
    human.reset
    computer.reset
    Round.reset
  end

  def bad_hands
    computer_losses = []
    bad_hands = []
    Round.winners.each_with_index do |winner, index|
      computer_losses << computer.hands[index] if winner == human.name
    end
    computer_losses.uniq.each do |hand|
      bad_hands << hand if (computer_losses.count(hand) / Round.rounds) >= LOSS_LIMIT
    end
    computer.bad_hands = bad_hands
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
      set_winner
      show_winner
      break if !play_again?
      bad_hands
      reset
      computer.adjust_ai
    end

    show_bye
  end
end

Game.new.play
