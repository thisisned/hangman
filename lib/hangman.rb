require 'json'

class Game

  def initialize
    puts "1. New Game\n2. Load Game"
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
    guess = gets.chomp.to_s.downcase
    if guess == "save"
      save_game
    elsif !guess.between?('a', 'z') || guess.length > 1
      puts "One letter please.\n\n"
      return false
    elsif @guesses.include?(guess)
      puts "Already guessed.\n\n"
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
    puts "Game saved"
    File.open("saves/test.txt", "w") {|save| save.write(serialize)}
    exit
  end

  def load_game
      JSON.load(File.open("saves/test.txt", 'r').read).each do |var,val|
      self.instance_variable_set '@'+var,val
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
        puts "\nLives left: #{@lives}"
        puts @feedback_string.join(' ')
        guess = get_guess
        if guess
          @guesses << guess
          check(guess)
        end
        puts "Guessed: #{@guesses.join(', ')}"
        if @lives < 1
          puts "\nNo lives left.\n\n"
          break
        end
        if @feedback_string.join == @word
          puts @feedback_string.join(' ')
          puts "\nYou win!\n\n"
          break
        end 
      end
      break unless play_again
    end
  end
end

Game.new