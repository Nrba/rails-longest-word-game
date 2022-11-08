# frozen_string_literal: false

require 'open-uri'
require 'json'

# This class inherits from application_controller
class GamesController < ApplicationController
  def new
    @grid = generate_grid(10)
    @start_time = Time.now
  end

  def score
    @end_time = Time.now
    @start_time = Time.parse(params[:start_time])
    @answer = params[:word]
    @grid = params[:grid].split('')
    @game = run_game(@answer, @grid, @start_time, @end_time)
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    Array.new(grid_size) { ('A'..'Z').to_a.sample }
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
    result = { time: end_time - start_time }

    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last

    result
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, 'well done']
      else
        [0, 'not an English word']
      end
    else
      [0, 'not in the grid']
    end
  end

  def english_word?(word)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{word.downcase}")
    json = JSON.parse(response.read)
    json['found']
  end
end
