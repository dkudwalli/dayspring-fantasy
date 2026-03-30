class PredictionHistoriesController < ApplicationController
  PER_PAGE = 20

  before_action :authenticate_user!

  def show
    @page = [params[:page].to_i, 1].max
    match_scope = Match.joins(prediction_questions: :predictions)
      .where(predictions: { user_id: current_user.id })
      .distinct
      .order(starts_at: :desc)

    @total_pages = [(match_scope.count(:id).to_f / PER_PAGE).ceil, 1].max
    @page = [@page, @total_pages].min
    @matches = match_scope.limit(PER_PAGE).offset((@page - 1) * PER_PAGE).to_a
    @match_points_by_id = current_user.predictions
      .joins(:prediction_question)
      .where(prediction_questions: { match_id: @matches.map(&:id) })
      .group("prediction_questions.match_id")
      .sum(Arel.sql(User::POINTS_CASE_SQL))

    @predictions_by_match = @matches.index_with { [] }
    current_user.predictions
      .joins(prediction_question: :match)
      .where(matches: { id: @matches.map(&:id) })
      .includes(:prediction_option, prediction_question: %i[correct_option match])
      .order("matches.starts_at DESC, prediction_questions.id ASC")
      .each do |prediction|
        @predictions_by_match[prediction.prediction_question.match] << prediction
      end
  end
end
