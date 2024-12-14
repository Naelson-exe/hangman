class Player
  attr_reader :name, :guesses

  def initialize(name = nil)
    if name.nil? || name.strip.empty?
      print "Enter your name: "
      name = gets.chomp.strip
    end
    @name = name
    @guesses = []
  end

  def make_guess
    puts "#{@name}, please enter your guess (a single letter):"
    guess = gets.chomp.downcase

    until valid_guess?(guess)
      puts "Invalid input. Please enter a single letter that you haven't guessed yet:"
      guess = gets.chomp.downcase
    end

    @guesses << guess
    guess
  end

  def valid_guess?(guess)
    guess.match?(/^[a-z]$/) && !already_guessed?(guess)
  end

  def already_guessed?(guess)
    @guesses.include?(guess)
  end

  def reset
    @guesses.clear
  end
end
