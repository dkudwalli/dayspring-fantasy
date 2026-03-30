class PredictionsController < ApplicationController
  before_action :authenticate_user!

  def create
    @match = Match.visible_to_users.includes(active_prediction_questions: %i[active_options correct_option]).find(prediction_params[:match_id])
    @selected_date = @match.starts_at.to_date
    questions = @match.active_prediction_questions.to_a
    open_questions = questions.select(&:open_for_predictions?)
    answers = prediction_params[:answers]&.to_h || {}

    if questions.empty?
      return render_prediction_response(alert: "No prediction questions found for this match.", status: :unprocessable_content)
    end

    if open_questions.empty?
      alert =
        if @match.locked? && questions.none?(&:result_published?)
          "Predictions are locked once the match starts."
        else
          "There are no open prediction questions for this match."
        end

      return render_prediction_response(alert: alert, status: :unprocessable_content)
    end

    if open_questions.any? { |question| answers[question.id.to_s].blank? }
      return render_prediction_response(alert: "Select one answer for every question before saving.", status: :unprocessable_content)
    end

    ActiveRecord::Base.transaction do
      open_questions.each do |question|
        prediction = current_user.predictions.find_or_initialize_by(prediction_question: question)
        action_type = prediction.persisted? ? "updated" : "created"
        prediction.assign_attributes(prediction_option_id: answers[question.id.to_s])
        prediction.save!

        PredictionSubmission.create!(
          user: current_user,
          match: @match,
          prediction_question: question,
          prediction_option: prediction.prediction_option,
          action_type: action_type,
          submitted_at: Time.current
        )
      end
    end

    render_prediction_response(notice: "Your picks have been saved.")
  rescue ActiveRecord::RecordInvalid => error
    render_prediction_response(alert: error.record.errors.full_messages.to_sentence, status: :unprocessable_content)
  end

  private

  def prediction_params
    params.require(:prediction).permit(:match_id, answers: {})
  end

  def render_prediction_response(notice: nil, alert: nil, status: :ok)
    respond_to do |format|
      format.html do
        flash[notice.present? ? :notice : :alert] = notice || alert
        redirect_to root_path(date: @selected_date)
      end

      format.turbo_stream do
        flash.now[notice.present? ? :notice : :alert] = notice || alert
        load_dashboard_state

        render turbo_stream: [
          turbo_stream.replace(
            "flash_messages",
            partial: "shared/flash_messages",
            locals: { messages: flash.to_hash }
          ),
          turbo_stream.replace(
            "dashboard_metrics",
            partial: "dashboard/metrics",
            locals: dashboard_metric_locals
          ),
          turbo_stream.replace(
            view_context.dom_id(@match, :dashboard_card),
            partial: "dashboard/match_card",
            locals: { match: @match, predictions_by_question_id: @predictions_by_question_id }
          )
        ], status: status
      end
    end
  end

  def load_dashboard_state
    @match = Match.visible_to_users.includes(active_prediction_questions: %i[active_options correct_option]).find(@match.id)
    question_ids = Match.visible_to_users.on_date(@selected_date)
      .includes(active_prediction_questions: %i[active_options correct_option])
      .flat_map { |match| match.active_prediction_questions.map(&:id) }

    @predictions_by_question_id = current_user.predictions
      .includes(:prediction_option)
      .where(prediction_question_id: question_ids)
      .index_by(&:prediction_question_id)
    @current_user_rank = User.rank_for(current_user)
  end

  def dashboard_metric_locals
    {
      selected_date: @selected_date,
      current_user_rank: @current_user_rank
    }
  end
end
