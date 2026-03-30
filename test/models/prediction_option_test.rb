require "test_helper"

class PredictionOptionTest < ActiveSupport::TestCase
  test "requires a label" do
    option = PredictionOption.new(
      prediction_question: prediction_questions(:open_winner),
      label: ""
    )

    assert_not option.valid?
    assert_includes option.errors[:label], "can't be blank"
  end

  test "cannot be destroyed when referenced as the correct option" do
    option = prediction_options(:open_powerplay_team_two_option)
    question = prediction_questions(:open_powerplay)
    question.update!(correct_option: option, result_published_at: Time.current)

    assert_no_difference("PredictionOption.count") do
      assert_not option.destroy
    end

    assert_includes option.errors.full_messages.to_sentence, "resolved questions"
  end
end
