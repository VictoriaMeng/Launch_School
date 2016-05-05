HANDS = { %w(rock r) => "Rock", %w(paper p) => "Paper", %w(scissors s) => "Scissors" }

WINNING_HANDS = { "Rock" => "Scissors", "Paper" => "Rock", "Scissors" => "Paper"}

class Player
  attr_reader :hand, :name

  def initialize(name)
    @name = name
  end

  def self.compare_hands(human, computer)
    if human.hand == computer.hand
      "tie"
    elsif WINNING_HANDS[human.hand] == computer.hand
      "human"
    else
      "computer"
    end
  end

  def self.announce_winner(human, computer, winner)
    case winner
    when "tie"
      say "You both picked #{human.hand}. It's a tie!"
    when "human"
      say "#{human.name} picked #{human.hand}. Computer picked #{computer.hand}. You win!"
    else
      say "#{human.name} picked #{human.hand}. Computer picked #{computer.hand}. You lose!"
    end
  end

  def choose_hand
    if @name == "Computer"
      @hand = HANDS.values.sample
    else
      input = validate_input
      match_input(input)
    end
  end

  def list_hands
    HANDS.values.each { | hand | say "Enter #{hand[0]} for #{hand}." }
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
    HANDS.keys.each { | set | @hand = HANDS[set] if set.include?(input) }
  end
end

class Round
  attr_accessor :rounds, :ties

  @@rounds = 0
  @@wins = 0
  @@losses = 0
  @@ties = 0

  def initialize
    @@rounds += 1
  end

  def self.tally_score(winner)
    @@wins += 1 if winner == "human"
    @@losses += 1 if winner == "computer"
    @@ties += 1 if winner == "tie"
  end

  def self.five_rounds_won?
    @@wins == 5 || @losses == 5
  end
end

def say(message)
  puts "--> #{message}"
end

def get_name
  say "What's your name?"
  gets.chomp
end

def show_intro
  say "Let's play Rock-Paper-Scissors. Win 5 rounds to win the game."
end

def play_again?
  begin
    say "Do you want to play again? Press 'Y' for yes. Press 'N' for no."
    input = gets.chomp
    input = input.downcase
  end until %w(y yes n no).include?(input)
  %w(y yes).include?(input)
end

human = Player.new(get_name)
computer = Player.new("Computer")
show_intro

loop do
  Round.new
  computer.choose_hand
  human.choose_hand
  result = Player.compare_hands(human, computer)
  Round.tally_score(result)
  Player.announce_winner(human, computer, result)
  break if !play_again? || Round.five_rounds_won?
end

puts "Thanks for playing!"