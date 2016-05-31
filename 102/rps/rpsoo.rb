require "yaml"

HANDS = { %w(rock r) => "Rock", %w(paper p) => "Paper", %w(scissors sc) => "Scissors", %w(spock sp) => "Spock", %w(lizard l) => "Lizard" }

LOSING_HANDS = { "Rock" => %w(Scissors Lizard), "Paper" => %w(Spock Rock), "Scissors" => %w(Lizard Paper), "Lizard" => %w(Spock Paper), "Spock" => %w(Rock Scissors) }

WIN_REQUIREMENT = 10

class Player
  attr_accessor :wins, :hands
  attr_reader :name

  def show_past_hands
    puts "#{name}'s previous hands - #{hands}"
  end
end

class Human < Player
  def initialize(name)
    @name = name
    @wins = 0
    @hands = []
  end

  def self.enter_name
    begin 
      puts "What's your name?"
      name = gets.chomp
    end while name.empty?
    name
  end

  def validate_input
    begin
      list_hands
      input = gets.chomp
      input = input.downcase
    end until HANDS.keys.flatten.include?(input)
    input
  end

  def match_input(input)
    HANDS.keys.each { |keys| hands << HANDS[keys] if keys.include?(input) }
  end

  def choose_hand
    input = validate_hand
    match_hand(input)
  end

  def list_hands
    HANDS.each { |keys, hand| puts "Enter '#{keys[1].upcase}' for #{hand}." }
  end
end

class Computer < Player
  def initialize
    @name = "Computer"
    @wins = 0
    @hands = []
  end

  def choose_hand
    hands << HANDS.values.sample
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
end

class Game
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
    compare_hands
    adjust_score
    show_round_winner
    show_score
    human.show_past_hands
    computer.show_past_hands
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
      puts "#{human.name} picked #{human.hands[-1]}. Computer picked #{computer.hands[-1]}. You win!"
    else
      puts "#{human.name} picked #{human.hands[-1]}. Computer picked #{computer.hands[-1]}. You lose!"
    end
  end

  def show_score
    puts "Score - #{human.name}: #{human.wins} - Computer: #{computer.wins} - Ties: #{Round.ties}"
  end

  def ten_points?
    human.wins == WIN_REQUIREMENT || computer.wins == WIN_REQUIREMENT
  end

  def set_winner
    @winner = human.name if human.wins == WIN_REQUIREMENT
    @winner = "Computer" if computer.wins == WIN_REQUIREMENT
  end

  def show_winner
    print "--> #{human.name} won #{human.wins} rounds. Computer won #{computer.wins} rounds. "
    case winner
    when human.name
      puts "You win!"
    else
      puts "You lose!"
    end
  end

  def show_bye
    puts "Thanks for playing!"
  end

  def play
    show_intro

    begin
      play_round
    end until ten_points?

    set_winner
    show_winner
    show_bye
  end
end

game = Game.new.play
