class Player
  attr_accessor :hand

  def initialize(deck)
    @hand = Hand.new(deck)
  end

  def blackjack?
    hand.blackjack?
  end

  def harden
    hand.harden
  end

  def value
    hand.value
  end

  def display
    hand.display
  end

  def hit(deck)
    hand.draw(deck)
  end

  def soft?
    hand.soft?
  end

  def hard?
    hand.hard?
  end

  def over_21?
    hand.over_21?
  end

  def bust?
    hard? && over_21?
  end

end

class Human < Player
  def turn(deck)
    loop do
      display
      break if blackjack?
      action = choose_action(deck)
      hand.harden
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

  attr_accessor :rank, :value, :suit

  def initialize(rank, suit)
    @rank = rank
    @value = RANK_VALUES[rank]
    @suit = suit
  end

  def text
    "#{rank} of #{suit}"
  end

  def harden_ace
    @rank = "Ace(1)"
    @value = 1
  end

  def soft_ace?
    value == 11
  end

end

class Hand
  attr_accessor :cards, :value

  def initialize(deck)
    @cards = []
    @value = 0
    2.times { draw(deck) }
  end

  def display
    puts "Cards - #{card_list.join(", ")} - Total: #{value}"
  end

  def card_list
    card_list = []
    cards.each { |card| card_list << card.text }
    card_list
  end

  def draw(deck)
    card = deck.random_card
    @cards << card
    @value += card.value
  end

  def count_soft_aces
    cards.select { |card| card.soft_ace? }.count
  end

  def harden
    cards.each do |card|
      break if hard? || !over_21? || bust?
      card.harden_ace if card.soft_ace?
      @value -= 10
    end
  end

  def blackjack?
    cards.count == 2 && value == 21
  end

  def soft?
    cards.any? { |card| card.soft_ace? }
  end

  def hard?
    cards.none? { |card| card.soft_ace? }
  end

  def over_21?
    value > 21
  end

  def bust?
    hard? && over_21?
  end
end

class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    full_deck
  end

  def full_deck
    Card::RANK_VALUES.each do |rank, _|
      Card::SUITS.each { |suit| @cards << Card.new(rank, suit) }
    end
  end

  def random_card
    cards.shuffle.pop
  end
end

class Game
  attr_accessor :deck, :human, :computer

  def initialize
    @deck = Deck.new
    @human = Human.new(deck)
    @computer = Computer.new(deck)
  end

  def play
    human.turn(deck)
    computer.turn(deck)
    result
  end

  def result
    if blackjack?
      blackjack_result
    elsif bust?
      bust_result
    else
      compare_players
    end
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
    if blackjack_tie?
      puts "You both got blackjack, but dealer wins ties! You lose!"
    elsif human.blackjack?
      puts "You got blackjack! You win!"
    else
      puts "Computer got blackjack! You win!"
    end
  end

  def bust_result
    result = computer.bust? ? "You busted! You lose!" : "Computer busted! You win!"
    puts result
  end

  def compare_players
    human_value = human.hand.value
    computer_value = computer.hand.value
    puts "You win!" if human_value > computer_value
    puts "You lose!" if computer_value > human_value
    puts "Dealer wins ties! You lose!" if human_value == computer_value
  end

end

Game.new.play

