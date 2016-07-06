class Player
  def initialize(deck)
    @hand = Hand.new(deck)
  end
end

class Human < Player
end

class Computer < Player
end

class Card
  SUITS = %w(Clubs Diamonds Hearts Spades).freeze
  RANK_VALUES = {}
  ranks = ("2".."10").to_a + %w(Jack Queen King Ace)
  values = (2..10).to_a + [10] * 3 
  ranks.each { |rank| values.each { |value| RANK_VALUES[rank] = value } }
  RANK_VALUES.freeze

  attr_accessor :rank, :value, :suit

  def initialize(rank, suit)
    @rank = rank
    @value = RANK_VALUES[rank]
    @suit = suit
  end
end

class Hand
  def initialize(deck)
    @cards = []
    2.times { draw(deck.random_card) }
  end

  def draw(card)
    @cards << card
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
    @cards.shuffle.pop
  end
end

class Game
  attr_accessor :deck, :human, :computer

  def initialize
    @deck = Deck.new
    @human = Human.new(deck)
    @computer = Computer.new(deck)
  end
end

Card::RANK_VALUES