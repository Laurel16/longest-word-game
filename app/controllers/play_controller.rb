require 'open-uri'
require 'json'

class PlayController < ApplicationController
  def game
    @start_time = Time.now
    @grid = generate_grid(16)
  end

  def generate_grid(grid_size)
    (0...grid_size).map { (65 + rand(26)).chr }
  end

  def score
    @choice = params[:choice]
    @start_time = Time.parse(params[:start_time])
    @grid = JSON.parse(params[:grid]) #ou params[:grid].split("")
    @end_time = Time.now
    @time = @end_time - @start_time
    @result = run_game(@choice, @grid, @start_time, @end_time)
  end
end

def run_game(choice, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result
  user_input = choice.upcase.split("")
  if (grid - user_input).size <= grid.size - user_input.size # word in the grid
    process_translation(choice.downcase,@time)
  else
    return { time: 0, translation: "", score: 0, message: "not in the grid" }
  end
end

def translation(choice)
  api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{choice}"
  open(api_url) do |stream|
    quote = JSON.parse(stream.read)
    if quote['term0']
      quote['term0']['PrincipalTranslations']['0']['FirstTranslation']['term']
    end
  end
end

def process_translation(choice, time)
  if translation(choice)
    translation = translation(choice)
    score = choice.length + 1 / time
    return { time: time, translation: translation, score: score, message: "well done" }
  else
    return { time: 0, translation: nil, score: 0, message: "not an english word" }
  end
end



#
# # Interface
# # puts "******** Welcome to the longest word-game !********"
# puts "Here is your grid :"
# grid = generate_grid(9)
# puts grid.join(" ")
# puts "*****************************************************"

# puts "What's your best shot ?"
# start_time = Time.now
# attempt = gets.chomp
# end_time = Time.now

# puts "******** Now your result ********"

# result = run_game(attempt, grid, start_time, end_time)

# puts "Your word: #{attempt}"
# puts "Time Taken to answer: #{result[:time]}"
# puts "Translation: #{result[:translation]}"
# puts "Your score: #{result[:score]}"
# puts "Message: #{result[:message]}"

# puts "*****************************************************"

