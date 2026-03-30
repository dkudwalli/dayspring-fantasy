require "test_helper"

class PredictionsFlowTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  test "prediction submission requires authentication" do
    travel_to(Time.zone.parse("2026-04-10 18:00:00")) do
      assert_no_difference("Prediction.count") do
        post predictions_path, params: prediction_params(
          matches(:open_match),
          prediction_options(:open_team_two_option),
          prediction_options(:open_powerplay_team_two_option)
        )
      end
    end

    assert_redirected_to new_session_path
  end

  test "submitting picks creates predictions and audit entries" do
    sign_in_as(users(:rival))

    travel_to(Time.zone.parse("2026-04-10 18:00:00")) do
      assert_difference("Prediction.count", 2) do
        assert_difference("PredictionSubmission.count", 2) do
          post predictions_path, params: prediction_params(
            matches(:open_match),
            prediction_options(:open_team_two_option),
            prediction_options(:open_powerplay_team_two_option)
          )
        end
      end
    end

    assert_redirected_to root_path(date: matches(:open_match).starts_at.to_date)
    assert_equal %w[created created], PredictionSubmission.order(:id).last(2).map(&:action_type)
  end

  test "resubmitting picks updates existing predictions and writes update audit logs" do
    sign_in_as(users(:member))

    travel_to(Time.zone.parse("2026-04-10 18:15:00")) do
      assert_no_difference("Prediction.count") do
        assert_difference("PredictionSubmission.count", 2) do
          post predictions_path, params: prediction_params(
            matches(:open_match),
            prediction_options(:open_team_two_option),
            prediction_options(:open_powerplay_team_two_option)
          )
        end
      end
    end

    assert_redirected_to root_path(date: matches(:open_match).starts_at.to_date)
    assert_equal %w[updated updated], PredictionSubmission.order(:id).last(2).map(&:action_type)
    assert_equal prediction_options(:open_team_two_option), predictions(:member_open_winner).reload.prediction_option
    assert_equal prediction_options(:open_powerplay_team_two_option), predictions(:member_open_powerplay).reload.prediction_option
  end

  test "all questions must be answered before saving" do
    sign_in_as(users(:rival))

    travel_to(Time.zone.parse("2026-04-10 18:00:00")) do
      assert_no_difference("Prediction.count") do
        assert_no_difference("PredictionSubmission.count") do
          post predictions_path, params: {
            prediction: {
              match_id: matches(:open_match).id,
              answers: {
                prediction_questions(:open_winner).id.to_s => prediction_options(:open_team_two_option).id
              }
            }
          }
        end
      end
    end

    assert_redirected_to root_path(date: matches(:open_match).starts_at.to_date)
    follow_redirect!
    assert_match "Select one answer for every question before saving.", response.body
  end

  test "locked matches reject submissions" do
    sign_in_as(users(:rival))

    travel_to(Time.zone.parse("2026-04-05 19:31:00")) do
      assert_no_difference("Prediction.count") do
        assert_no_difference("PredictionSubmission.count") do
          post predictions_path, params: {
            prediction: {
              match_id: matches(:locked_match).id,
              answers: {
                prediction_questions(:locked_winner).id.to_s => prediction_options(:locked_team_one_option).id
              }
            }
          }
        end
      end
    end

    assert_redirected_to root_path(date: matches(:locked_match).starts_at.to_date)
    follow_redirect!
    assert_match "Predictions are locked once the match starts", response.body
  end

  test "published questions do not require new answers and cannot be edited" do
    sign_in_as(users(:member))
    prediction_questions(:open_winner).update!(
      correct_option: prediction_options(:open_team_one_option),
      result_published_at: Time.current
    )

    travel_to(Time.zone.parse("2026-04-10 18:15:00")) do
      assert_no_difference("Prediction.count") do
        assert_difference("PredictionSubmission.count", 1) do
          post predictions_path, params: {
            prediction: {
              match_id: matches(:open_match).id,
              answers: {
                prediction_questions(:open_powerplay).id.to_s => prediction_options(:open_powerplay_team_two_option).id
              }
            }
          }
        end
      end
    end

    assert_equal prediction_options(:open_team_one_option), predictions(:member_open_winner).reload.prediction_option
    assert_equal prediction_options(:open_powerplay_team_two_option), predictions(:member_open_powerplay).reload.prediction_option
  end

  private

  def prediction_params(match, winner_option, powerplay_option)
    {
      prediction: {
        match_id: match.id,
        answers: {
          prediction_questions(:open_winner).id.to_s => winner_option.id,
          prediction_questions(:open_powerplay).id.to_s => powerplay_option.id
        }
      }
    }
  end
end
