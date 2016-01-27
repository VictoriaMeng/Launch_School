require "yaml"
MESSAGES = YAML.load_file("21_msgs.yml")
lang = "en"

TARGET = 21
DEALER_STAND_VALUE = 16

def say(message)
  puts "> #{message}"
end

def prompt(lang, message)
  puts MESSAGES[lang][message]
end

def announce(message)
  puts "\n--- #{message} ---"
  puts "\n"
end

def prompt_announce(lang, message)
  announce MESSAGES[lang][message]
end

def enter_name(lang, message)
  prompt_announce(lang, message)
  gets.chomp
end

def deck
  (2..10).to_a.concat(%w(Jack Queen King Ace(11))).product(%w(Hearts Diamonds Clubs Spades))
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

def ace_adjust(hand)
  for card in hand[:cards] do
    if card[0] == "Ace(11)" && hand[:total] > TARGET
      card[0] = "Ace(1)"
      hand[:total] -= 10
    end
  end
end

def deal_card(deck, hand)
  card = deck.delete(deck.sample)
  hand[:cards].push(card)
  hand[:total] += card_value(card[0])
  ace_adjust(hand)
  card
end

def card_name(card)
  "#{card[0]} of #{card[1]}"
end

def show_card_dealt(card, message)
  say "#{message} #{card_name(card)}."
end

def print_hand(name, hand)
  cards = hand[:cards].map { |card| card_name(card).to_s }.flatten
  puts "#{name}'s Hand: #{cards} --- Total: #{hand[:total]}"
end

def show_one_card(hand)
  first_card = hand.first
  puts <<~SHOW_CARD
    Dealer Shows: #{card_name(first_card)} --- \
    Value: #{card_value(first_card[0])}
  SHOW_CARD
end

def blackjack_check(hands)
  return "blackjack_tie" if hands[:player][:total] == TARGET && hands[:dealer][:total] == TARGET
  return "blackjack_player" if hands[:player][:total] == TARGET
  return "blackjack_dealer" if hands[:dealer][:total] == TARGET
  nil
end

def player_action(message)
  begin
    announce(message)
    action = gets.chomp
    action = action.downcase
  end until %w(h s).include?(action)
  action
end

def player_turn(name, deck, hand, message)
  begin
    action = player_action(message["hit_stand"])
    case action
    when "s"
      turn_end = "stand"
    else
      card = deal_card(deck, hand)
      show_card_dealt(card, message["show_card_dealt"])
      print_hand(name, hand)
      turn_end = "player_bust" if hand[:total] > TARGET
    end
  end until turn_end
  turn_end
end

def dealer_turn(deck, hand, message)
  until hand[:total] > DEALER_STAND_VALUE
    card = deal_card(deck, hand)
    show_card_dealt(card, message)
  end
  print_hand("Dealer", hand)
  return "dealer_bust" if hand[:total] > TARGET
  "stand"
end

def compare_hands(hands)
  return "tie" if hands[:player][:total] == hands[:dealer][:total]
  return "player_standard_win" if hands[:player][:total] > hands[:dealer][:total]
  return "dealer_standard_win" if hands[:player][:total] < hands[:dealer][:total]
end

def print_winner(name, game_end, messages)
  if messages["player_win"].keys.include?(game_end)
    announce "#{name} #{messages["player_win"][game_end]}"
  else
    announce messages["player_lose"][game_end].to_s
  end
end

def play_again?(lang, message)
  begin
    prompt(lang, message)
    answer = gets.chomp
    yes_no = answer.downcase
  end until %w(y n).include?(yes_no)
  yes_no == "y"
end

loop do
  eight_decks = []
  eight_decks = deck * 8

  name = enter_name(lang, "enter_name")
  hands = { player: { cards: [],
                       total: 0
                    },
            dealer: { cards: [],
                       total: 0
                    }
          }

  2.times do
    deal_card(eight_decks, hands[:player])
    deal_card(eight_decks, hands[:dealer])
  end

  if blackjack_check(hands)
    game_end = blackjack_check(hands)
  else
    print_hand(name, hands[:player])
    show_one_card(hands[:dealer][:cards])
    player_turn_end = player_turn(name, eight_decks, hands[:player], MESSAGES[lang])

    if player_turn_end == "player_bust"
      game_end = "player_bust"
    else
      print_hand("Dealer", hands[:dealer])
      dealer_turn_end = dealer_turn(eight_decks, hands[:dealer], MESSAGES[lang]["show_card_dealt"])
      game_end = "dealer_bust" if dealer_turn_end == "dealer_bust"
      game_end = compare_hands(hands) if dealer_turn_end == "stand"
    end
  end

  prompt_announce(lang, "final_results")
  print_hand(name, hands[:player])
  print_hand("Dealer", hands[:dealer])
  print_winner(name, game_end, MESSAGES[lang]["results"])

  break unless play_again?(lang, "play_again")
end

prompt(lang, "thanks")
