# Methods that format text
def prompt(msg)
  puts "==> #{msg}"
end

def display_cards(cards, d1=', ', d2='and')
  # Lists the cards nicely for the player.
  output = ''

  if cards.size == 2
    output = "#{cards[0]} #{d2} #{cards[1]}"
  else
    cards[0..-2].each { |card| output += "#{card}#{d1}" }
    output += "#{d2} #{cards.last}"
  end

  output
end

def conceal_last_card(card_string)
  words = card_string.split
  words.pop
  words << "an unknown card"
  words.join(' ')
end

def display_dealer_cards(cards)
  conceal_last_card(display_cards((cards)))
end

def goodbye_msg
  prompt("Thank you for playing Blackjack!")
end

# Methods that create or modify cards
def initialize_deck
  suit = %w(Ace 2 3 4 5 6 7 8 9 10 Jack Queen King)
  deck = suit * 4
  deck.shuffle!
end

def deal_cards!(deck)
  c1, c2 = deck.shift, deck.shift
end

def hit!(cards, deck)
  cards << deck.shift
end

# Methods that read cards
def get_total_value(cards)
  # Split the aces from the non-aces.
  aces, non_aces = cards.partition { |card| card == 'Ace' }

  # Calculate the value of the non-aces first.
  non_aces_value = get_non_aces_value(non_aces)

  # Calculate the value of the aces based on the previous value.
  # Combine both values for the total value.
  non_aces_value + get_aces_value(aces, non_aces_value)
end

def get_non_aces_value(cards)
  cards.reduce(0) do |value, card|
    %w(2 3 4 5 6 7 8 9 10).include?(card) ? value += card.to_i : value += 10
  end
end

def get_aces_value(cards, value)
  cards.reduce(0) do |aces_value, card|
    if value + 11 <= 21
      value += 11
      aces_value += 11
    else
      value += 1
      aces_value += 1
    end
  end
end

# Methods concerning endgame conditions.
def blackjack?(cards)
  cards.include?('Ace') &&
    (cards.include?('10') || cards.include?('Jack') ||
    cards.include?('Queen') || cards.include?('King'))
end

def busted?(cards)
  get_total_value(cards) > 21
end

def detect_winner(player, dealer)
  if get_total_value(player) > get_total_value(dealer)
    'player'
  elsif get_total_value(player) == get_total_value(dealer)
    'tie'
  else
    'dealer'
  end
end

def display_winner(outcome)
  case outcome
  when 'player' then prompt("You win!")
  when 'tie'    then prompt("It's a tie!")
  when 'dealer' then prompt("You lose.")
  end
end

# Start of game. Deal cards.
prompt("Welcome to Blackjack!")

deck = initialize_deck

dealer_cards = deal_cards!(deck)
prompt("Dealer's cards: #{display_dealer_cards(dealer_cards)}.")

player_cards = deal_cards!(deck)
prompt("Your cards: #{display_cards(player_cards)}.")

# Check for blackjacks. Consider refactoring this code.
if blackjack?(dealer_cards) && blackjack?(player_cards)
  prompt("Both of you have blackjacks. It's a tie!")
  goodbye_msg
  exit
elsif blackjack?(dealer_cards)
  prompt("Dealer has blackjack. You lose.")
  goodbye_msg
  exit
elsif blackjack?(player_cards)
  prompt("You have blackjack. You win!")
  goodbye_msg
  exit
end

# Player's turn
loop do
  prompt("Would you like to hit ('h') or stay ('s')?")

  action = gets.chomp

  if action.downcase[0] == 'h'
    hit!(player_cards, deck)
    prompt("Your cards: #{display_cards(player_cards)}.")
    break if busted?(player_cards)
    next
  end

  break if action.downcase[0] == 's'

  prompt("That was an invalid choice. Please enter 'h' or 's'.")
end

# Check if the player busted 21.
if busted?(player_cards)
  prompt("You lost. You have busted 21.")
  prompt("The total value of your cards is #{get_total_value(player_cards)}.")
  goodbye_msg
  exit
else
  prompt("You chose to stay.")
end

# Dealer's turn
prompt("It is now the dealer's turn.")

loop do
  break if get_total_value(dealer_cards) >= 17
  hit!(dealer_cards, deck)
end

prompt("Dealer's cards: #{display_cards(dealer_cards)}.")
prompt("Dealer's points: #{get_total_value(dealer_cards)}.")

# Check if the dealer busted 21.
if busted?(dealer_cards)
  prompt("The dealer has busted 21.")
  prompt("You win!")
  goodbye_msg
  exit
end

prompt("Your cards: #{display_cards(player_cards)}.")
prompt("Your points: #{get_total_value(player_cards)}.")

winner = detect_winner(player_cards, dealer_cards)
display_winner(winner)
goodbye_msg

# Consider implementing a replay mechanic.
# prompt("Do you want to play another round of Blackjack? (y/n)")
# answer = gets.chomp
# break unless answer.downcase[0] == 'y'
