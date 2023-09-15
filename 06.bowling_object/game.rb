# frozen_string_literal: true

require './shot'
require './frame'

STRIKE_SCORE = 10
TOTAL_GAME_COUNT = 10

class Game
  attr_reader :total_score

  def initialize(shots)
    result_frames = calc_frame_results(shots)
    @total_score = calc_total_score(result_frames)
  end

  private

  def calc_frame_results(shots)
    frames = create_frames(shots)

    frames.each_with_index do |frame, i|
      frame.calc_result_score(frames, i)
    end
  end

  def create_frames(shots)
    separate_frames(shots).map { |frames_score_point| Frame.new(frames_score_point) }
  end

  def separate_frames(shots)
    frames_score_points = []
    tmp_scores = []
    shots.split(',').each do |shot|
      if tmp_scores.empty? && shot == 'X' && frames_score_points.size < TOTAL_GAME_COUNT - 1
        frames_score_points << [shot]
        tmp_scores = []
      else
        tmp_scores << shot
        if tmp_scores.size == 2
          frames_score_points << tmp_scores
          tmp_scores = [] unless frames_score_points.size == TOTAL_GAME_COUNT
        end
      end
    end

    frames_score_points
  end

  def calc_total_score(frames)
    frames.sum(&:result_score)
  end
end
