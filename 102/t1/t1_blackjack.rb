class Player
  attr_reader :name, :value, :cards

  def initialize(deck)
    reset(deck)
  end

  def reset(deck)
    @cards = []
    @value = 0
    2.times { hit(deck) }
  end

  def to_s
    "#{name}'s Hand - #{card_list.join(', ')} - Total: #{value}"
  end

  def display
    puts to_s
  end

  def card_list
    card_list = []
    cards.each { |card| card_list << card.to_s }
    card_list
  end

  def hit(deck)
    card = deck.random_card
    cards << card
    total_value
    harden
  end

  def harden
    cards.each do |card|
      break if hard? || !over_21? || bust?
      card.harden_ace if card.soft_ace?
      total_value
    end
  end

  def total_value
    card_values = []
    cards.each { |card| card_values << card.value }
    @value = card_values.reduce(:+)
  end

  def blackjack?
    cards.count == 2 && value == 21
  end

  def harden_ace?(card)
    value > 21 && card.ace?
  end

  def soft?
    cards.any?(&:soft_ace?)
  end

  def hard?
    cards.none?(&:soft_ace?)
  end

  def over_21?
    value > 21
  end

  def bust?
    hard? && over_21?
  end
end

class Human < Player
  def initialize(deck)
    super
    @name = enter_name
  end

  def enter_name
    input = ""
    puts "What's your name?"
    loop do
      input = gets.strip
      break unless input.empty?
      puts "Please enter your name."
    end
    input
  end

  def turn(deck)
    loop do
      display
      action = choose_action(deck)
      break if turn_end(action)
    end
  end

  def choose_action(deck)
    input = ""
    loop do
      puts "Enter 'H' to hit, 'S' to stand."
      input = gets.strip
      input = input.downcase
      break if %w(h hit s stand).include?(input)
    end
    return "stand" if stand?(input)
    hit(deck) if hit?(input)
  end

  def hit?(input)
    %w(h hit).include?(input)
  end

  def stand?(input)
    %w(s stand).include?(input)
  end

  def turn_end(action)
    bust? || action == "stand"
  end
end

class Computer < Player
  def initialize(deck)
    super
    @name = "Dealer"
  end

  def turn(deck)
    loop do
      display
      break if blackjack? || stand?
      hit(deck)
    end
  end

  def hit?
    value <= 16
  end

  def stand?
    value > 16
  end

  def show_one_card
    puts "#{name} Card - '#{card_list[0]}'"
  end
end

class Card
  SUITS = %w(Clubs Diamonds Hearts Spades).freeze
  RANK_VALUES = {}
  ranks = ("2".."10").to_a + %w(Jack Queen King Ace(11))
  values = (2..10).to_a + [10] * 3 + [11]
  ranks.each { |rank| RANK_VALUES[rank] = "" }
  RANK_VALUES.each_with_index do |(rank, _), index|
    RANK_VALUES[rank] = values[index]
  end
  RANK_VALUES.freeze

  attr_reader :rank, :value, :suit

  def initialize(rank, suit)
    @rank = rank
    @value = RANK_VALUES[rank]
    @suit = suit
  end

  def to_s
    "#{rank} of #{suit}"
  end

  def harden_ace
    @rank = "Ace(1)"
    @value = 1
  end

  def ace?
    rank.include?("Ace")
  end

  def soft_ace?
    value == 11
  end
end

class Deck
  attr_reader :cards

  def initialize
    @cards = []
    reset
  end

  def reset
    8.times { fifty_two_cards }
    cards.shuffle!
  end

  def fifty_two_cards
    Card::RANK_VALUES.each do |rank, _|
      Card::SUITS.each { |suit| @cards << Card.new(rank, suit) }
    end
  end

  def random_card
    cards.pop
  end
end

class Game
  attr_reader :deck, :human, :computer

  def initialize
    @deck = Deck.new
    @human = Human.new(deck)
    @computer = Computer.new(deck)
  end

  def play
    loop do
      round unless blackjack?
      result
      break unless play_again?
      reset(deck)
    end
    show_bye
  end

  private

  def round
    computer.show_one_card
    human.turn(deck)
    computer.turn(deck) unless human.bust?
  end

  def display_players
    human.display
    computer.display
  end

  def result
    display_players
    return blackjack_result if blackjack?
    return bust_result if bust?
    standard_result
  end

  def blackjack?
    human.blackjack? || computer.blackjack?
  end

  def blackjack_tie?
    human.blackjack? && computer.blackjack?
  end

  def bust?
    human.bust? || computer.bust?
  end

  def blackjack_result
    return puts blackjack_tie_text if blackjack_tie?
    return puts human_blackjack_text if human.blackjack?
    puts computer_blackjack_text
  end

  def bust_result
    result = human.bust? ? human_bust_text : computer_bust_text
    puts result
  end

  def standard_result
    puts human_win_text if human_win?
    puts computer_win_text if computer_win?
    puts tie_text if tie?
  end

  def human_win?
    human.value > computer.value
  end

  def computer_win?
    computer.value > human.value
  end

  def tie?
    human.value == computer.value
  end

  def blackjack_tie_text
    "You both got blackjack, but dealer wins ties! You lose!"
  end

  def human_blackjack_text
    "#{human.name} got blackjack! You win!"
  end

  def computer_blackjack_text
    "#{computer.name} got blackjack! You lose!"
  end

  def human_bust_text
    "#{human.name} busted! You lose!"
  end

  def computer_bust_text
    "#{computer.name} busted! You win!"
  end

  def human_win_text
    "#{human.value} beats #{computer.value}. You win!"
  end

  def computer_win_text
    "#{computer.value} beats #{human.value}. You lose!"
  end

  def tie_text
    "#{computer.name} wins ties! You lose!"
  end

  def play_again?
    input = ""
    puts "Play again? Enter 'y' for yes, 'n' for no."
    loop do
      input = gets.chomp
      input = input.downcase
      break if %w(y yes n no).include?(input)
      puts "Please enter 'y' for yes, 'n' for no."
    end
    %w(y yes).include?(input)
  end

  def reset(deck)
    deck.reset
    human.reset(deck)
    computer.reset(deck)
  end

  def show_bye
    puts "Thanks for playing!"
  end
end

Game.new.play
