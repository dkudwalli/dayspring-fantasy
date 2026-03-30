require "test_helper"

class PredictionHistoriesTest < ActionDispatch::IntegrationTest
  test "signed in users can view their graded prediction history" do
    sign_in_as(users(:member))
    prediction_questions(:locked_winner).update!(
      correct_option: prediction_options(:locked_team_one_option),
      result_published_at: Time.current
    )

    get prediction_history_path

    assert_response :success
    assert_match "Your picks timeline", response.body
    assert_match matches(:locked_match).name, response.body
    assert_match "Your pick:", response.body
    assert_match "Correct answer:", response.body
    assert_match prediction_options(:locked_team_one_option).label, response.body
    assert_match "4 pts", response.body
  end

  test "prediction history paginates by match" do
    sign_in_as(users(:member))

    21.times do |index|
      match = Match.create!(
        team_one: "History Team #{index}",
        team_two: "History Rival #{index}",
        venue: "Venue #{index}",
        starts_at: Time.zone.local(2026, 6, 1, 19, 30) + index.days
      )
      question = match.prediction_questions.create!(prompt: "Question #{index}", point_value: 1)
      option = question.options.create!(label: match.team_one, position: 0)
      question.options.create!(label: match.team_two, position: 1)
      users(:member).predictions.create!(prediction_question: question, prediction_option: option)
    end

    get prediction_history_path(page: 2)

    assert_response :success
    assert_match "Page 2 of 2", response.body
    assert_match "History Team 0 vs History Rival 0", response.body
  end
end
