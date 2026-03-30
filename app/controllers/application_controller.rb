class ApplicationController < ActionController::Base
  include Authentication

  around_action :tag_logs_with_request_context

  private

  def tag_logs_with_request_context(&block)
    Rails.logger.tagged(
      "request_id=#{request.request_id}",
      "user_id=#{current_user&.id || 'guest'}",
      "admin=#{current_user&.admin? ? 1 : 0}",
      &block
    )
  end
end
