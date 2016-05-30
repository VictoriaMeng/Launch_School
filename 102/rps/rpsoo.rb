require "yaml"

HANDS = { %w(rock r) => "Rock", %w(paper p) => "Paper", %w(scissors sc) => "Scissors", %w(spock sp) => "Spock", %w(lizard l) => "Lizard" }

LOSING_HANDS = { "Rock" => %w(Scissors Lizard), "Paper" => %w(Spock Rock), "Scissors" => %w(Lizard Paper), "Lizard" => %w(Spock Paper), "Spock" => %w(Rock Scissors) }

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

  def validate_hand
    begin
      list_hands
      input = gets.chomp
      input = input.downcase
    end until HANDS.keys.flatten.include?(input)
    input
  end

  def match_hand(input)
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
  @@rounds = 0
  @@ties = 0
  @@round_winners = []

  def initialize
    @@rounds += 1
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

  def self.round_winners
    @@round_winners
  end

  def self.next_round?
    begin
      puts "Play next round? Press 'Y' for yes. Press 'N' for no."
      input = gets.chomp
      input = input.downcase
    end until %w(y yes n no).include?(input)
    %w(y yes).include?(input)
  end
end

class Game
  attr_accessor :human, :computer

  attr_reader :winner

  def initialize
    @human = Human.new(Human.enter_name)
    @computer = Computer.new
  end

  def show_intro
    puts "Let's play Rock-Paper-Scissors-Lizard-Spock. Win 10 rounds to win the game!"
  end

  def play_round
    computer.choose_hand
    human.choose_hand
    compare_hands
    show_round_winner
    show_score
    human.show_past_hands
    computer.show_past_hands
  end

  def compare_hands
    if human.hands[-1] == computer.hands[-1]
      Round.add_tie
      Round.round_winners << "tie"
    elsif LOSING_HANDS[human.hands[-1]].include?(computer.hands[-1])
      human.wins += 1
      Round.round_winners << human.name
    else
      computer.wins += 1
      Round.round_winners << "Computer"
    end
  end

  def show_round_winner
    case Round.round_winners[-1]
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
    human.wins == 10 || computer.wins == 10
  end

  def set_game_winner
    @winner = human.name if human.wins == 10
    @winner = "Computer" if computer.wins == 10
  end

  def show_game_winner
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
end

game = Game.new
game.show_intro

begin
  Round.new
  game.play_round
end until game.ten_points?

game.set_game_winner
game.show_game_winner

game.show_bye
