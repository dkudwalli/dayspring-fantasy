module DashboardHelper
  def dashboard_match_state(match, questions)
    return { label: "Setup needed", tone: :warning, description: "No active questions yet" } if questions.empty?
    return { label: "Graded", tone: :success, description: "Results published" } if questions.all?(&:result_published?)
    return { label: "Locked", tone: :danger, description: "Predictions closed at toss" } if match.locked?

    {
      label: "Open",
      tone: :accent,
      description: "#{pluralize(questions.count, 'question')} live"
    }
  end

  def winner_prediction_for_match(match, questions, predictions_by_question_id)
    winning_question = questions.find do |question|
      option_labels = question.active_options.map(&:label)
      option_labels.include?(match.team_one) && option_labels.include?(match.team_two)
    end

    predictions_by_question_id[winning_question&.id]
  end

  def answered_questions_for_match(questions, predictions_by_question_id)
    questions.count { |question| predictions_by_question_id[question.id].present? }
  end
end
