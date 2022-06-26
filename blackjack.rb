LINE = "-------------------------------------"

# Methods that affect text output
def prompt(msg)
  puts "==> #{msg}"
end

def display_all_cards(cards, d1=', ', d2='and')
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
  conceal_last_card(display_all_cards((cards)))
end

def display_bj_winner(outcome)
  case outcome
  when 'player' then prompt("You have a blackjack hand. You won!")
  when 'tie'    then prompt("You and the dealer have blackjack hands. It's a tie!")
  when 'dealer' then prompt("The dealer has a blackjack hand. You lost. Better luck next time!")
  end
end

def display_winner(outcome)
  case outcome
  when 'player' then prompt("You won!")
  when 'tie'    then prompt("It's a tie!")
  when 'dealer' then prompt("You lost. Better luck next time!")
  end
end

# Methods that create, read, or modify cards
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

def get_total_value(cards)
  total_value = 0

  cards.each do |card|
    if %w(2 3 4 5 6 7 8 9 10).include?(card)
      total_value += card.to_i
    elsif %w(Jack Queen King).include?(card)
      total_value += 10
    else
      total_value += 11
    end
  end

  aces = cards.count("Ace")
  aces.times { total_value -= 10 if total_value > 21 } if aces > 0

  total_value
end

# Methods that involve endgame situations.
def blackjack?(cards)
  cards.include?('Ace') &&
    (cards.include?('10') || cards.include?('Jack') ||
    cards.include?('Queen') || cards.include?('King'))
end

def busted?(cards)
  get_total_value(cards) > 21
end

def detect_bj_winner(player, dealer)
  if blackjack?(dealer) && blackjack?(player)
    'tie'
  elsif blackjack?(dealer)
    'dealer'
  elsif blackjack?(player)
    'player'
  else
    nil
  end
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

def play_again
  puts LINE
  prompt("Would you like to play another round of Blackjack? (y/n)")
  answer = gets.chomp.downcase
  answer[0] == 'y'
end

# Game loops until the player decides to quit.
loop do
  # Start of game. Deal cards.
  puts LINE
  prompt("Welcome to Blackjack! ♠ ♥ ♦ ♣")
  deck = initialize_deck
  dealer_cards = deal_cards!(deck)
  player_cards = deal_cards!(deck)

  # Check for blackjack hands at the outset.
  bj_winner = detect_bj_winner(player_cards, dealer_cards)
  if bj_winner != nil
    prompt("Dealer's cards: #{display_all_cards(dealer_cards)}.")
    prompt("Your cards: #{display_all_cards(player_cards)}.")
    display_bj_winner(bj_winner)
    play_again ? next : break
  end

  prompt("Dealer's cards: #{display_dealer_cards(dealer_cards)}.")
  prompt("Your cards: #{display_all_cards(player_cards)}.")

  # Player's turn
  loop do
    prompt("Your points: #{get_total_value(player_cards)}.")
    prompt("Would you like to hit (h) or stay (s)?")

    action = gets.chomp.downcase
    if action[0] == 'h'
      hit!(player_cards, deck)
      prompt("You chose to hit.")
      prompt("Your cards are now: #{display_all_cards(player_cards)}.")
      break if busted?(player_cards)
      next
    end

    break if action[0] == 's'

    prompt("That was an invalid choice. Please enter 'h' or 's'.")
  end

  # There are two ways of reaching this point of the code.
  # 1) The player busted. 2) The player did not bust and chose to stay.
  if busted?(player_cards)
    prompt("You lost. You have busted 21.")
    prompt("The total value of your cards is #{get_total_value(player_cards)}.")
    prompt("Better luck next time!")
    play_again ? next : break
  else
    prompt("You chose to stay.")
  end

  # Dealer's turn
  puts LINE
  prompt("It is the dealer's turn now.")

  loop do
    break if get_total_value(dealer_cards) >= 17
    hit!(dealer_cards, deck)
  end

  prompt("Dealer's cards: #{display_all_cards(dealer_cards)}.")
  prompt("Dealer's points: #{get_total_value(dealer_cards)}.")

  # Check if the dealer busted 21.
  if busted?(dealer_cards)
    prompt("The dealer has busted 21.")
    prompt("You won!")
    play_again ? next : break
  end

  prompt("Your cards: #{display_all_cards(player_cards)}.")
  prompt("Your points: #{get_total_value(player_cards)}.")

  winner = detect_winner(player_cards, dealer_cards)
  display_winner(winner)
  play_again ? next : break
end

puts LINE
prompt("Thank you for playing Blackjack!")
