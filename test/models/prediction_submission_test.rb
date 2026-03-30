require "test_helper"

class PredictionSubmissionTest < ActiveSupport::TestCase
  test "question must belong to the selected match" do
    submission = PredictionSubmission.new(
      user: users(:member),
      match: matches(:open_match),
      prediction_question: prediction_questions(:locked_winner),
      prediction_option: prediction_options(:locked_team_one_option),
      action_type: "created",
      submitted_at: Time.current
    )

    assert_not submission.valid?
    assert_includes submission.errors[:prediction_question_id], "must belong to the selected match"
  end

  test "option must belong to the selected question" do
    submission = PredictionSubmission.new(
      user: users(:member),
      match: matches(:open_match),
      prediction_question: prediction_questions(:open_winner),
      prediction_option: prediction_options(:open_powerplay_team_one_option),
      action_type: "created",
      submitted_at: Time.current
    )

    assert_not submission.valid?
    assert_includes submission.errors[:prediction_option_id], "must belong to the selected question"
  end

  test "action type must be from the allowed set" do
    submission = PredictionSubmission.new(
      user: users(:member),
      match: matches(:open_match),
      prediction_question: prediction_questions(:open_winner),
      prediction_option: prediction_options(:open_team_one_option),
      action_type: "deleted",
      submitted_at: Time.current
    )

    assert_not submission.valid?
    assert_includes submission.errors[:action_type], "is not included in the list"
  end

  test "database constraint rejects mismatched question and match pairs" do
    assert_raises(ActiveRecord::InvalidForeignKey) do
      PredictionSubmission.insert_all!([
        {
          user_id: users(:member).id,
          match_id: matches(:open_match).id,
          prediction_question_id: prediction_questions(:locked_winner).id,
          prediction_option_id: prediction_options(:locked_team_one_option).id,
          action_type: "created",
          submitted_at: Time.current,
          created_at: Time.current,
          updated_at: Time.current
        }
      ])
    end
  end
end
