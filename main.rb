require_relative 'lib/game'

def welcome
  puts 'Select mode: (1) New game; (2) Load game; (q) Quit'
  choice = gets.chomp

  case choice
  when '1'
    puts 'Enter your name:'
    player_name = gets.chomp.strip

    if File.exist?("saved_games/#{player_name}.json")
      puts "A saved game already exists for #{player_name}. Starting a new game will overwrite the save. Proceed? (y/n)"
      overwrite_choice = gets.chomp.downcase
      if overwrite_choice != 'y'
        puts 'Enter a different name or return to the main menu by typing "menu".'
        new_name = gets.chomp.strip
        player_name = new_name unless new_name.downcase == 'menu'
        welcome if new_name.downcase == 'menu'
      end
    end

    Game.new(player_name, method(:welcome)).start

  when '2'
    saved_games = Dir["saved_games/*.json"].map { |file| File.basename(file, '.json') }
    if saved_games.empty?
      puts 'No saved games found.'
      welcome
    else
      puts 'Saved games:'
      saved_games.each_with_index { |game, index| puts "#{index + 1}. #{game}" }

      puts 'Enter the name associated with the saved game:'
      player_name = gets.chomp.strip

      if saved_games.include?(player_name)
        Game.load(player_name, method(:welcome)).start
      else
        puts "No saved game found for #{player_name}. Try again."
        welcome
      end
    end
  when 'q'
    puts "Goodbye!"
    exit
  else
    puts 'Invalid choice. Try again.'
    welcome
  end
end

welcome
