require "test_helper"

class PredictionQuestionTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  test "#open_for_predictions? mirrors the match lock state" do
    question = prediction_questions(:open_winner)

    travel_to(Time.zone.parse("2026-04-10 19:29:59")) do
      assert question.open_for_predictions?
    end

    travel_to(Time.zone.parse("2026-04-10 19:30:00")) do
      assert_not question.open_for_predictions?
    end
  end

  test "correct option must belong to the same question" do
    question = prediction_questions(:open_winner)
    question.correct_option = prediction_options(:open_powerplay_team_one_option)

    assert_not question.valid?
    assert_includes question.errors[:correct_option_id], "must belong to this question"
  end

  test "published results require a correct option" do
    question = prediction_questions(:open_winner)
    question.result_published_at = Time.current

    assert_not question.valid?
    assert_includes question.errors[:correct_option_id], "must be selected before publishing results"
  end

  test "database constraint rejects a correct option from another question" do
    question = prediction_questions(:open_winner)

    assert_raises(ActiveRecord::InvalidForeignKey) do
      question.class.where(id: question.id).update_all(correct_option_id: prediction_options(:open_powerplay_team_one_option).id)
    end
  end
end
