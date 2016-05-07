HANDS = { %w(rock r) => "Rock", %w(paper p) => "Paper", %w(scissors s) => "Scissors" }

WINNING_HANDS = { "Rock" => "Scissors", "Paper" => "Rock", "Scissors" => "Paper"}

class Player
  attr_accessor :wins, :winner

  attr_reader :hand, :name

  @@winner = nil

  def initialize(name)
    @name = name
    @wins = 0
  end

  def self.compare_hands(human, computer)
    if human.hand == computer.hand
      Round.add_tie
      self.show_round_winner(human, computer, "tie")
    elsif WINNING_HANDS[human.hand] == computer.hand
      human.wins += 1
      self.show_round_winner(human, computer, "human")
    else
      computer.wins += 1
      self.show_round_winner(human, computer, "computer")
    end
  end

  def self.show_round_winner(human, computer, winner)
    case winner
    when "tie"
      say "You both picked #{human.hand}. It's a tie!"
    when "human"
      say "#{human.name} picked #{human.hand}. Computer picked #{computer.hand}. You win!"
    else
      say "#{human.name} picked #{human.hand}. Computer picked #{computer.hand}. You lose!"
    end
  end

  def self.set_game_winner(human, computer)
    @@winner = human.name if human.wins > computer.wins
    @@winner = "Computer" if computer.wins > human.wins
    @@winner = "tie" if human.wins == computer.wins
  end

  def self.game_winner
    @@winner
  end

  def self.show_game_winner(human, computer)
    print "--> #{human.name} won #{human.wins} rounds. Computer won #{computer.wins} rounds. "
    case @@winner
    when human.name
      puts "You win!"
    when "Computer"
      puts "You lose!"
    else
      puts "It's a tie!"
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
  @@rounds = 0
  @@ties = 0

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

  def self.five_rounds?
    @@rounds == 5
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
  say "Let's play Rock-Paper-Scissors. Best of 5 wins the game!"
end

def play_round(human, computer)
  Round.new
  computer.choose_hand
  human.choose_hand
  Player.compare_hands(human, computer)
  Player.show_score(human, computer)
end

def show_score(human, computer)
  say "Rounds Played: #{Round.rounds} - Wins: #{human.wins} - Losses: #{computer.wins} - Ties: #{Round.ties}"
end

def play_again?
  begin
    say "Play next round? Press 'Y' for yes. Press 'N' for no."
    input = gets.chomp
    input = input.downcase
  end until %w(y yes n no).include?(input)
  %w(y yes).include?(input)
end

def show_bye
  say "Thanks for playing!"
end

human = Player.new(get_name)
computer = Player.new("Computer")
show_intro

begin
  play_round(human, computer)
end until !play_again? || Round.five_rounds?

Player.set_game_winner(human, computer)
Player.show_game_winner(human, computer) if Player.game_winner
show_bye