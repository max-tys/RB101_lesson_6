LINE = "-------------------------------------"
MAX_POINTS = 21
MIN_DEALER_POINTS = 17

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
  when 'tie'    then prompt("Both of you have blackjack hands. It's a tie!")
  when 'dealer' then prompt("The dealer has a blackjack hand. You lost.")
  end
end

def display_winner(outcome)
  case outcome
  when 'player' then prompt("You won!")
  when 'tie'    then prompt("It's a tie!")
  when 'dealer' then prompt("You lost.")
  end
end

def display_score(score)
  prompt("Player: #{score['player']}, Dealer: #{score['dealer']}.")
end

# Methods that create, read, or modify cards
def initialize_deck
  suit = %w(Ace 2 3 4 5 6 7 8 9 10 Jack Queen King)
  deck = suit * 4
  deck.shuffle!
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
  aces.times { total_value -= 10 if total_value > MAX_POINTS } if aces > 0

  total_value
end

# Methods that involve endgame situations.
def blackjack?(cards)
  cards.include?('Ace') &&
    (cards.include?('10') || cards.include?('Jack') ||
    cards.include?('Queen') || cards.include?('King'))
end

def busted?(points)
  points > MAX_POINTS
end

def detect_bj_winner(player, dealer)
  if blackjack?(dealer) && blackjack?(player)
    'tie'
  elsif blackjack?(dealer)
    'dealer'
  elsif blackjack?(player)
    'player'
  end
end

def detect_winner(p_points, d_points)
  if p_points > d_points
    'player'
  elsif p_points == d_points
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
score = { 'player' => 0, 'dealer' => 0, 'tie' => 0 }
loop do
  # Start of game. Deal cards.
  puts LINE
  prompt("Welcome to Blackjack! ♠ ♥ ♦ ♣")
  deck = initialize_deck
  dealer_cards = []
  player_cards = []
  2.times do
    dealer_cards << deck.shift
    player_cards << deck.shift
  end

  # Check for blackjack hands at the outset.
  bj_winner = detect_bj_winner(player_cards, dealer_cards)
  if !bj_winner.nil?
    prompt("Dealer's cards: #{display_all_cards(dealer_cards)}.")
    prompt("Your cards: #{display_all_cards(player_cards)}.")
    display_bj_winner(bj_winner)
    score[bj_winner] += 1
    break if score['player'] == 3 || score['dealer'] == 3
    display_score(score)
    play_again ? next : break
  end

  # If there are no blackjack hands, display the cards on the 'table'.
  prompt("Dealer's cards: #{display_dealer_cards(dealer_cards)}.")
  prompt("Your cards: #{display_all_cards(player_cards)}.")

  # Player's turn
  player_points = get_total_value(player_cards) # Cached to improve performance.
  loop do
    prompt("Your points: #{player_points}.")
    prompt("Would you like to hit (h) or stay (s)?")

    action = gets.chomp.downcase
    if action[0] == 'h'
      hit!(player_cards, deck)
      prompt("You chose to hit.")
      prompt("Your cards are now: #{display_all_cards(player_cards)}.")
      player_points = get_total_value(player_cards) # Updates on each hit.
      break if busted?(player_points)
      next
    end

    break if action[0] == 's'

    prompt("That was an invalid choice. Please enter 'h' or 's'.")
  end

  # There are two ways of reaching this point of the code.
  # 1) The player busted. 2) The player did not bust and chose to stay.
  if busted?(player_points)
    prompt("You lost. You have busted #{MAX_POINTS}.")
    prompt("The total value of your cards is #{player_points}.")
    score['dealer'] += 1
    break if score['player'] == 3 || score['dealer'] == 3
    display_score(score)
    play_again ? next : break
  else
    prompt("You chose to stay.")
  end

  # Dealer's turn. Will repeatedly hit until he has at least 17 points.
  puts LINE
  prompt("It is the dealer's turn now.")

  loop do
    break if get_total_value(dealer_cards) >= MIN_DEALER_POINTS
    hit!(dealer_cards, deck)
  end

  # Display the dealer's cards when he's done (either busted or has enough pts)
  dealer_points = get_total_value(dealer_cards)
  prompt("Dealer's cards: #{display_all_cards(dealer_cards)}.")
  prompt("Dealer's points: #{dealer_points}.")

  # Check if the dealer busted.
  if busted?(dealer_points)
    prompt("The dealer has busted #{MAX_POINTS}.")
    prompt("You won!")
    score['player'] += 1
    break if score['player'] == 3 || score['dealer'] == 3
    display_score(score)
    play_again ? next : break
  end

  # Display the player's cards and the winner.
  prompt("Your cards: #{display_all_cards(player_cards)}.")
  prompt("Your points: #{player_points}.")
  winner = detect_winner(player_points, dealer_points)
  display_winner(winner)
  score[winner] += 1
  break if score['player'] == 3 || score['dealer'] == 3
  display_score(score)

  # Ask if the player wants another round of Blackjack.
  # We do away with 'next' since this is the last line of code in the main loop.
  break unless play_again
end

puts LINE
prompt(":: FINAL SCORE ::")
display_score(score)
prompt("Thank you for playing Blackjack. Goodbye!")
