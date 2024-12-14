class SecretWord
  attr_reader :word, :revealed_letters, :attempted_letters, :remaining_attempts
  
  def initialize
    @word = get_word
    @revealed_letters = Array.new(@word.length, '_')
    @attempted_letters = []
    @remaining_attempts = @word.length
  end

  def get_word
    File.open('words.txt', 'r') do |file|
      file.each_line.map(&:strip).select { |word| word.length.between?(5, 12) }.sample
    end
  end

  def in_word?(letter)
    @word.include?(letter)
  end

  def reveal_letter(letter)
    @word.chars.each_with_index do |char, index|
      @revealed_letters[index] = char if char == letter
    end
  end

  def add_attempted_letter(letter)
    return if @attempted_letters.include?(letter)

    @attempted_letters << letter
    if is_letter_in_word?(letter)
      reveal_letter(letter)
    else
      @remaining_attempts -= 1
    end
  end

  def current_state
    @revealed_letters.join(' ')
  end

  def all_letters_revealed?
    !@revealed_letters.include?('_')
  end

  def game_over?
    @remaining_attempts.zero? || all_letters_revealed?
  end

  def reset
    @word = get_word
    @revealed_letters = Array.new(@word.length, '_')
    @attempted_letters = []
    @remaining_attempts = @word.length
  end
end
