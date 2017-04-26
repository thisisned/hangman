require 'json'

class Game

  def initialize
    puts "\n1. New Game\n2. Load Game\n"
    print "> "
    case gets.chomp.to_i
    when 1
      reset
      play
    when 2
      load_game
      play
    else
      puts "1 or 2 please"
    end
  end

  def reset
    @guesses = []
    @word = get_word
    @feedback_string = Array.new(@word.length, "_")
    @lives = 10
  end

  def get_word
    dictionary = File.readlines("5desk.txt")
    dictionary.each { |word| word.chomp! }
    word_list = dictionary.select { |word| word.length.between?(5, 12) && /[a-z]/.match(word[0]) }
    return word_list.sample
  end

  def get_guess
    print "\nGuess (or type 'save' to save and quit): > "
    guess = gets.chomp.to_s.downcase
    if guess == "save"
      save_game
    elsif !guess.between?('a', 'z') || guess.length > 1
      puts "\nOne letter please.\n"
      return false
    elsif @guesses.include?(guess)
      puts "\nAlready guessed.\n"
      return false
    else return guess
    end
  end

  def check guess
    correct = 0
    @word.split('').each_with_index do |char, index|
      if guess == char
        @feedback_string[index] = guess
        correct += 1
      end
    end
    @lives -= 1 if correct == 0
  end

  def play_again
    puts "Play again? y/n"
    print "> "
    return false unless gets.chomp.downcase == "y"
    reset
    true
  end

  def save_game
    puts "Save name?"
    print "> "
    save_name = gets.chomp
    File.open("saves/#{save_name}", "w") {|save| save.write(serialize)}
    puts "Game saved"
    exit
  end

  def load_game
    saved_games = Dir["saves/*"]
    if saved_games.empty?
      puts "No saved games. See ya."
      exit
    end
    saved_games.each_with_index do |save, n|
      puts "#{n+1}. #{save[6..-1]}"
    end
    loop do
      print "> "
      load_choice = gets.chomp.to_i
      if load_choice.between?(1, saved_games.length)
        JSON.load(File.open(saved_games[load_choice - 1], 'r').read).each do |var,val|
          self.instance_variable_set '@'+var,val
        end
        break
      end
    end
  end

  def serialize
    {"word" => @word,
     "guesses" => @guesses,
     "lives" => @lives,
     "feedback_string" => @feedback_string}.to_json
   end

   def play
    loop do
      while true
        puts "\n" + @feedback_string.join(' ')
        puts "\nLives left: #{@lives} || Guessed: #{@guesses.join(', ')}\n"
        guess = get_guess
        if guess
          @guesses << guess
          check(guess)
        end
        if @lives < 1
          puts "\nNo lives left.\n\n"
          break
        end
        if @feedback_string.join == @word
          puts "\n" + @feedback_string.join(' ')
          puts "\nYou win!\n\n"
          break
        end 
      end
      break unless play_again
    end
  end
end

Game.new