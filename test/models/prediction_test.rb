require "test_helper"

class PredictionTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  test "option must belong to the selected question" do
    prediction = Prediction.new(
      user: users(:rival),
      prediction_question: prediction_questions(:open_winner),
      prediction_option: prediction_options(:open_powerplay_team_one_option)
    )

    assert_not prediction.valid?
    assert_includes prediction.errors[:prediction_option_id], "must belong to the selected question"
  end

  test "user can only submit one prediction per question" do
    duplicate = Prediction.new(
      user: users(:member),
      prediction_question: prediction_questions(:open_winner),
      prediction_option: prediction_options(:open_team_two_option)
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "predictions are invalid once the match has started" do
    travel_to(Time.zone.parse("2026-04-10 19:31:00")) do
      late_prediction = Prediction.new(
        user: users(:rival),
        prediction_question: prediction_questions(:open_winner),
        prediction_option: prediction_options(:open_team_two_option)
      )

      assert_not late_prediction.valid?
      assert_includes late_prediction.errors[:base], "Predictions are locked once the match starts"
    end
  end

  test "#correct? matches the question result" do
    prediction_questions(:locked_winner).update!(
      correct_option: prediction_options(:locked_team_one_option),
      result_published_at: Time.current
    )

    assert predictions(:member_locked_winner).correct?
    assert_not predictions(:rival_locked_winner).correct?
  end

  test "predictions are invalid once results are published" do
    prediction_questions(:open_winner).update!(
      correct_option: prediction_options(:open_team_two_option),
      result_published_at: Time.current
    )

    late_prediction = Prediction.new(
      user: users(:rival),
      prediction_question: prediction_questions(:open_winner),
      prediction_option: prediction_options(:open_team_two_option)
    )

    assert_not late_prediction.valid?
    assert_includes late_prediction.errors[:base], "Predictions are locked because results have been published"
  end

  test "database constraint rejects selecting an option from another question" do
    assert_raises(ActiveRecord::InvalidForeignKey) do
      Prediction.insert_all!([
        {
          user_id: users(:rival).id,
          prediction_question_id: prediction_questions(:open_winner).id,
          prediction_option_id: prediction_options(:open_powerplay_team_one_option).id,
          created_at: Time.current,
          updated_at: Time.current
        }
      ])
    end
  end
end
