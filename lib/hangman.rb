require 'yaml'
# load in dictionary
  # randomly select word between 5 and 12 characters long for the secret word

words = []

lines = File.readlines('google-10000-english-no-swears.txt')

lines.each do |line|
  word = line.strip
  word_length = line.strip.length
  # puts "word: #{line.strip}, length: #{line.strip.length}"

  if word_length > 4 && word_length < 13 
    words.push(word)
    # puts "word: #{word}, length: #{word_length}"
  end
end



class Hangman
  attr_accessor :correct_display, :incorrect_display, :amt_incorrect, :chosen_word, :allowed_incorrect, :chosen_word_split

  def initialize(words)
    @allowed_incorrect = 5
    @chosen_word = words.sample
    @correct_display = Array.new(chosen_word.length, '_')
    @incorrect_display = Array.new()
    @amt_incorrect = 0

    puts "The chosen word is #{@chosen_word}, length: #{@chosen_word.length}\n\n"
    @chosen_word_split = @chosen_word.split("")
    puts "Hangman initialized."
  end
  
  def print_displays
    p @correct_display
    puts "incorrect letters: #{@incorrect_display}, You have #{@allowed_incorrect - @amt_incorrect} incorrect guesses left."    
  end

  def to_yaml(username)
    File.open("./saved_profiles/#{username}.yaml", "w") do |file|
      file.puts YAML.dump ({
      :correct_display => @correct_display,
      :incorrect_display => @incorrect_display,
      :amt_incorrect => @amt_incorrect,
      :chosen_word => @chosen_word,
      :allowed_incorrect => @allowed_incorrect,
      :chosen_word_split => @chosen_word_split
    })
    end
    puts "Game saved."
  end

  def from_yaml(username)
    data = YAML.load(File.read("./saved_profiles/#{username}.yaml"))
    p data
    @correct_display = data[:correct_display]
    @incorrect_display = data[:incorrect_display]
    @amt_incorrect = data[:amt_incorrect]
    @chosen_word = data[:chosen_word]
    @allowed_incorrect = data[:allowed_incorrect]
    @chosen_word_split = data[:chosen_word_split]
    puts "Game data loaded."
  end 
end

load_profile = nil
game = Hangman.new(words)

until load_profile == true || load_profile == false
  # show profiles to load
  files = Dir.glob("./saved_profiles/*.yaml")
  # remove everything but the name
  files.each do |file|
    puts file[17..-6]
  end
  puts "Enter a profile to load in a previous game state or press enter to start a new game"
  
  user_input = gets.chomp
  if user_input != ""
    # load in data
    game.from_yaml(user_input)
    load_profile = true
  else
    load_profile = false
  end

  game.print_displays
  
end

game_saved = false

until game.correct_display.none?('_') || game.amt_incorrect == game.allowed_incorrect || game_saved == true do

  puts "Guess a letter or type 'save' to save the game: "
  user_choice = gets.chomp

  case user_choice
  when "save"
    puts "Enter a username to save your data"
    username = gets.chomp
    game_saved = true
    game.to_yaml(username)
  else
    letter = user_choice
    if game.chosen_word_split.include?(letter)
      game.chosen_word_split.each_with_index do |ltr, idx|
        if ltr == letter
          game.correct_display[idx] = letter
        end
      end
    else
      game.incorrect_display.push(letter)
      game.amt_incorrect += 1
    end
  
    game.print_displays
  end
end

if game.correct_display.none?('_')
  puts "You win"
else
  puts "You lose"
  puts "The word was: #{game.chosen_word}"
end


# What should be serialized? correct_display, incorrect_display, amt_incorrect, chosen_word




