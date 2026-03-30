require "test_helper"

class PredictionsRoutingTest < ActionDispatch::IntegrationTest
  test "predictions only expose a create route" do
    assert_routing(
      { method: "post", path: "/predictions" },
      { controller: "predictions", action: "create" }
    )

    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/predictions/1", method: :patch)
    end
  end
end
