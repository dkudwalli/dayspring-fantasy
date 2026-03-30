require "test_helper"

class AdminQuestionsTest < ActionDispatch::IntegrationTest
  test "non-admin users cannot access the admin area" do
    sign_in_as(users(:member))

    get admin_root_path

    assert_redirected_to root_path
    follow_redirect!
    assert_match "Admin access only.", response.body
  end

  test "admins can set the correct option for a question" do
    sign_in_as(users(:admin_user))

    question = prediction_questions(:open_winner)
    option = prediction_options(:open_team_two_option)

    patch admin_match_question_path(question.match, question), params: {
      prediction_question: {
        prompt: question.prompt,
        point_value: question.point_value,
        correct_option_id: option.id,
        publish_result: "1"
      }
    }

    assert_redirected_to edit_admin_match_path(question.match)
    assert_equal option, question.reload.correct_option
    assert question.result_published?
  end

  test "admins can archive and restore questions" do
    sign_in_as(users(:admin_user))
    question = prediction_questions(:open_winner)

    patch archive_admin_match_question_path(question.match, question)
    assert question.reload.archived?

    patch restore_admin_match_question_path(question.match, question)
    assert_not question.reload.archived?
  end

  test "admins cannot delete options that are already in use" do
    sign_in_as(users(:admin_user))
    option = prediction_options(:open_team_one_option)

    assert_no_difference("PredictionOption.count") do
      delete admin_match_question_option_path(option.prediction_question.match, option.prediction_question, option)
    end

    assert_redirected_to edit_admin_match_question_path(option.prediction_question.match, option.prediction_question)
    assert PredictionOption.exists?(option.id)
  end
end
