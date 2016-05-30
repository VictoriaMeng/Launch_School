require "yaml"

HANDS = { %w(rock r) => "Rock", %w(paper p) => "Paper", %w(scissors s) => "Scissors" }

LOSING_HANDS = { "Rock" => "Scissors", "Paper" => "Rock", "Scissors" => "Paper" }

class Player
  attr_accessor :wins, :hand
  attr_reader :name
end

class Human < Player
  def initialize(name)
    @name = name
    @wins = 0
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
    HANDS.keys.each { |set| @hand = HANDS[set] if set.include?(input) }
  end

  def choose_hand
    input = validate_hand
    match_hand(input)
  end

  def list_hands
    HANDS.values.each { |hand| puts "Enter #{hand[0]} for #{hand}." }
  end
end

class Computer < Player
  def initialize
    @name = "Computer"
    @wins = 0
  end

  def choose_hand
    @hand = HANDS.values.sample
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

  def self.five_rounds?
    @@rounds == 5
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
    puts "Let's play Rock-Paper-Scissors. Best of 5 wins the game!"
  end

  def play_round
    computer.choose_hand
    human.choose_hand
    compare_hands
    show_round_winner
    show_score
  end

  def compare_hands
    if human.hand == computer.hand
      Round.add_tie
      Round.round_winners << "tie"
    elsif LOSING_HANDS[human.hand] == computer.hand
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
      puts "You both picked #{human.hand}. It's a tie!"
    when human.name
      puts "#{human.name} picked #{human.hand}. Computer picked #{computer.hand}. You win!"
    else
      puts "#{human.name} picked #{human.hand}. Computer picked #{computer.hand}. You lose!"
    end
  end

  def show_score
    puts "Score - #{human.name}: #{human.wins} - Computer: #{computer.wins} - Ties: #{Round.ties}"
  end

  def set_game_winner
    @winner = human.name if human.wins > computer.wins
    @winner = "Computer" if computer.wins > human.wins
    @winner = "tie" if human.wins == computer.wins
  end

  def show_game_winner
    print "--> #{human.name} won #{human.wins} rounds. Computer won #{computer.wins} rounds. "
    case winner
    when human.name
      puts "You win!"
    when "Computer"
      puts "You lose!"
    else
      puts "It's a tie!"
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
end until Round.five_rounds? || !Round.next_round?

if Round.five_rounds?
  game.set_game_winner
  game.show_game_winner
end

game.show_bye
