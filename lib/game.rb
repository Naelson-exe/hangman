require 'json'
require_relative 'player'
require_relative 'secret_word'

class Game
  def initialize(player_name, secret_word = nil, attempted_letters = [], revealed_letters = [], remaining_attempts = nil, welcome_method = nil)
    @player = Player.new(player_name)
    @secret_word = secret_word || SecretWord.new
    @secret_word.attempted_letters = attempted_letters unless attempted_letters.empty?
    @secret_word.revealed_letters = revealed_letters unless revealed_letters.empty?
    @game_over = false
    @remaining_attempts = remaining_attempts || @secret_word.word.length
    @welcome_method = welcome_method
  end

  def start
    puts "Welcome to Hangman, #{@player.name}!"
    display_state

    until game_over?
      guess = @player.make_guess
      process_guess(guess)
      display_state

      case prompt_save?  
      when :save
        save_game
        puts "Game saved! You can resume later."
        return  
      when :quit
        puts "Quitting to welcome screen..."
        return_to_welcome  
      end
    end

    puts "Game over!"
    if @secret_word.all_letters_revealed?
      puts "Congratulations! You've guessed the word: #{@secret_word.word}"
    else
      puts "Sorry, you've run out of attempts. The word was: #{@secret_word.word}"
    end
  end
  

  def save_game
    save_data = {
      player_name: @player.name,
      secret_word: @secret_word.word,
      attempted_letters: @secret_word.attempted_letters,
      revealed_letters: @secret_word.revealed_letters,
      remaining_attempts: @secret_word.remaining_attempts
    }

    File.write("saved_games/#{@player.name}.json", JSON.pretty_generate(save_data))
    puts "Game saved! You can resume later."

    clear_screen
    @welcome_method.call
  end


  def self.load(player_name, welcome_method)
    save_file = "saved_games/#{player_name}.json"
    if File.exist?(save_file)
      save_data = JSON.parse(File.read(save_file))
      new(
        save_data['player_name'],
        SecretWord.new(save_data['secret_word']),
        save_data['attempted_letters'],
        save_data['revealed_letters'],
        save_data['remaining_attempts'],
        welcome_method
      )
    else
      puts "No saved game found for #{player_name}."
      clear_screen
      welcome_method.call  
    end
  end

  private

  def process_guess(guess)
    if @secret_word.in_word?(guess)
      puts "Good guess! '#{guess}' is in the word."
      @secret_word.reveal_letter(guess)
    else
      puts "Incorrect guess. '#{guess}' is not in the word."
      @secret_word.add_attempted_letter(guess)
    end
  end

  def display_state
    puts "Word: #{@secret_word.current_state}"
    puts "Attempts remaining: #{@secret_word.remaining_attempts}"
    puts "Guessed letters: #{@secret_word.attempted_letters.join(', ')}"
  end

  def game_over?
    @secret_word.game_over?
  end

  def prompt_save?
    puts "Would you like to save your game? (y/n) or (q to quit to welcome screen)"
    choice = gets.chomp.downcase
    if choice == 'y'
      return :save   
    elsif choice == 'q'
      return :quit   
    else
      return :continue  
    end
  end

  def clear_screen
    if Gem.win_platform?
      system('cls')
    else
      system('clear')
    end
  end

  def return_to_welcome
    @welcome_method.call  
  end
end