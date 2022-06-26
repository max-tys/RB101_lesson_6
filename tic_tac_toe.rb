WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # columns
                [[1, 5, 9], [3, 5, 7]]              # diagonals
INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'

# Methods that format text.
def prompt(msg)
  puts "==> #{msg}"
end

def display_board(brd)
  system 'clear'
  puts ""
  puts "You're a #{PLAYER_MARKER}. Computer is #{COMPUTER_MARKER}."
  puts "     |     |"
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}"
  puts "     |     |"
  puts ""
end

def get_first_player
  loop do
    prompt "Who should go first? (1 / 2 / 3)"
    prompt "1) Player"
    prompt "2) Computer"
    prompt "3) Random"

    first_player = gets.chomp

    case first_player
    when '1' then return 'player'
    when '2' then return 'computer'
    when '3' then return ['player', 'computer'].sample
    end

    prompt "Invalid choice. Please type 1, 2, or 3."
  end
end

def joinor(keys, d1=', ', d2='or')
  # Lists the available spaces on the 3x3 grid nicely for the player.
  output = ''

  case keys.size
  when 1 then output = "#{keys[0]}"
  when 2 then output = "#{keys[0]} #{d2} #{keys[1]}"
  else
    keys.each do |pos|
      break if pos == keys.last
      output += "#{pos.to_s}#{d1}"
    end
    output += "#{d2} #{keys.last.to_s}"
  end

  output
end

# Methods that read the position of the board pieces.
def initialize_board
  # Returns a hash that keeps track of the pieces on the board.
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def empty_squares(brd)
  # Returns an array of keys that correspond to empty squares.
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

# Methods that modify the board
def place_piece!(brd, current_player)
  if current_player == 'player'
    player_places_piece!(brd)
  else
    computer_places_piece!(brd)
  end
end

def alternate_player(current_player)
  current_player == 'player' ? 'computer' : 'player'
end

def player_places_piece!(brd)
  square = ''

  loop do
    prompt "Choose a square (#{joinor(empty_squares(brd))}): "
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    prompt "Sorry, that's not a valid choice."
  end

  brd[square] = PLAYER_MARKER
end

def computer_places_piece!(brd)
  # Offense first. The computer will make the winning move if it can.
  if find_hot_square(brd, COMPUTER_MARKER)
    square = find_hot_square(brd, COMPUTER_MARKER)
  # Defence second. Computer tries to prevent you from winning if it can't win.
  elsif find_hot_square(brd, PLAYER_MARKER)
    square = find_hot_square(brd, PLAYER_MARKER)
  # If no one is close to winning, computer will try to fill square 5.
  # If that's been filled, computer will fill a random square.
  elsif brd[5] == ' '
    square = 5
  else
    square = empty_squares(brd).sample
  end

  brd[square] = COMPUTER_MARKER
end

def find_hot_square(brd, marker)
  # Scans each winning line.
  WINNING_LINES.each do |line|
    # Examine the board condition for the given line. E.g. ["O", "O", " "]
    brd_line = [brd[line[0]], brd[line[1]], brd[line[2]]]

    # If 2 sqs are filled by the same marker, and there's a space on that line,
    # return the position of the empty space.
    if brd_line.count(INITIAL_MARKER) == 1 &&
       brd_line.count(marker) == 2
      line.each { |sq| return sq if brd[sq] == ' ' }
    end
  end

  # If there are no squares that, if filled, would end the game, return nil.
  nil
end

# Methods to detect end-game conditions
def board_full?(brd)
  empty_squares(brd).empty?
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if [brd[line[0]], brd[line[1]], brd[line[2]]].all?(PLAYER_MARKER)
      return 'Player'
    elsif [brd[line[0]], brd[line[1]], brd[line[2]]].all?(COMPUTER_MARKER)
      return 'Computer'
    end
  end
  nil
end

# Keep score with a hash
scores = { 'Player' => 0, 'Computer' => 0 }

# Main program
loop do
  board = initialize_board

  current_player = get_first_player

  # Sub-loop to place pieces until end-game condition is met.
  loop do
    display_board(board)
    place_piece!(board, current_player)
    current_player = alternate_player(current_player)
    break if someone_won?(board) || board_full?(board)
  end

  display_board(board)

  if someone_won?(board)
    prompt "#{detect_winner(board)} won this round!"
    scores[detect_winner(board)] += 1
    prompt "Player: #{scores['Player']}, Computer: #{scores['Computer']}."
  else
    prompt "It's a tie!"
  end

  if scores.values.any?(3)
    prompt "#{scores.key(3)} is the overall winner!"
    break
  end

  prompt "Continue playing? (y/n)"
  answer = gets.chomp
  break unless answer.downcase.start_with?('y')
end

prompt "Thanks for playing Tic Tac Toe! Good bye."
