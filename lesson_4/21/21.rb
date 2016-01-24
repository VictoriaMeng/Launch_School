require "yaml"
MESSAGES = YAML.load_file("21_msgs.yml")
lang = "en"

def say(message)
  puts "--> #{message}"
end

def instruct(instructions)
  puts " --- #{instructions} --- "
end

def enter_name(message)
  instruct "#{message}"
  name = gets.chomp
end

def new_deck
  deck = (2..10).to_a.concat(%w(Jack Queen King Ace(11))).product(%w(Hearts Diamonds Clubs Spades))
end

def card_value(card)
  case card
  when 2..10
    card
  when "Ace(11)"
    11
  else
    10
  end
end

def deal_card(deck, hand)
  card = deck.delete(deck.sample)
  hand[:cards].push(card)
  hand[:total] += card_value(card[0])
  card
end

def ace_adjust(hand)
  for card in hand[:cards] do 
    if card[0] == "Ace(11)" && hand[:total] > 21
      card[0] = "Ace(1)"
      hand[:total] -= 10
    end
  end
end

def announce_card(card)
  puts "Dealer deals a #{card[0]} of #{card[1]}."
end

def print_hand(name, hand)
  cards = hand[:cards].map {|card| "#{card[0]} of #{card[1]}"}.flatten
  puts "#{name}'s Hand: #{cards} --- Total: #{hand[:total]}"
end

def show_one_card(hand)
  first_card = hand.first
  puts "Dealer Shows: '#{first_card[0]} of #{first_card[1]}' --- Value: #{card_value(first_card[0])}"
end

def blackjack_check(hands)
  return "blackjack_tie" if hands[:player][:total] == 21 && hands[:dealer][:total] == 21
  return "blackjack_player" if hands[:player][:total] == 21
  return "blackjack_dealer" if hands[:dealer][:total] == 21
  nil
end

def player_turn(name, deck, hand)
  begin
    instruct "Type 'H' to hit. Type 'S' to stand."
    action = gets.chomp
  end until action.downcase == "h" || action.downcase == "s"

  case action.downcase
  when "h"
    card = deal_card(deck, hand)
    announce_card(card)
    ace_adjust(hand)
    print_hand(name, hand)
    return "player_bust" if hand[:total] > 21
    nil
  when "s"
    "stand"
  end
end

def dealer_turn(name, deck, hand)
  until hand[:total] > 16
    card = deal_card(deck, hand)
    announce_card(card)
    ace_adjust(hand)
    print_hand("Dealer", hand)
  end
  return "dealer_bust" if hand[:total] > 21
  "stand"
end 

def compare_hands(hands)
  return "tie" if hands[:player][:total] == hands[:dealer][:total]
  return "player_win" if hands[:player][:total] > hands[:dealer][:total]
  return "dealer_win" if hands[:player][:total] < hands[:dealer][:total]
end

def announce_winner(name, game_end)
  case game_end
  when "blackjack_tie"
    puts "You both get Blackjack, but dealer wins ties. You lose!"
  when "blackjack_dealer"
    puts "Dealer gets Blackjack! You lose!"
  when "blackjack_player"
    puts "#{name} gets Blackjack! You win!"
  when "tie"
    puts "Dealer wins ties. You lose!"
  when "player_bust"
    puts "#{name} busted! You lose!"
  when "dealer_bust"
    puts "Dealer busted! You win!"
  when "player_win"
    puts "Congratulations, #{name} wins!"
  when "dealer_win"
    puts "Sorry, #{name} loses!"
  end
end

loop do
  eight_decks = []
  eight_decks = new_deck * 8

  name = enter_name(MESSAGES[lang]["enter_name"])
  hands = {  player: {  cards: [], 
                       total: 0
                    },
            dealer: {  cards: [],
                       total: 0
                    }
          }

  2.times {deal_card(eight_decks, hands[:player])}
  2.times {deal_card(eight_decks, hands[:dealer])}

  if blackjack_check(hands)
    game_end = blackjack_check(hands)
  else
    print_hand(name, hands[:player])
    show_one_card(hands[:dealer][:cards])
    begin
      player_turn_end = player_turn(name, eight_decks, hands[:player])
    end until player_turn_end
    if player_turn_end == "player_bust"
      game_end = "player_bust"
    else
      print_hand("Dealer", hands[:dealer])
      dealer_turn_end = dealer_turn("Dealer", eight_decks, hands[:dealer])
      game_end = "dealer_bust" if dealer_turn_end == "dealer_bust"
      game_end = compare_hands(hands) if dealer_turn_end == "stand"
    end  
  end

  instruct "Final Results"
  print_hand(name, hands[:player])
  print_hand("Dealer", hands[:dealer])
  announce_winner(name, game_end)

  puts "Press 'Y' to play again. Press any other key to exit."
  play_again = gets.chomp
  break unless play_again.downcase == "y"
end

say "Thanks for playing!"