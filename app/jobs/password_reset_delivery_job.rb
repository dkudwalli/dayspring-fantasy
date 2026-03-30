class PasswordResetDeliveryJob < ApplicationJob
  queue_as :mailers

  retry_on Net::OpenTimeout, Net::ReadTimeout, Net::SMTPServerBusy, Timeout::Error, SocketError, EOFError, Errno::ECONNRESET, Errno::ECONNREFUSED, wait: :polynomially_longer, attempts: 5

  rescue_from(StandardError) do |error|
    Rails.logger.error("password_reset_delivery_failed user_id=#{arguments.first} error_class=#{error.class} message=#{error.message}")
    Sentry.capture_exception(error, extra: { job: self.class.name, user_id: arguments.first }) if defined?(Sentry)
    raise error
  end

  def perform(user_id)
    user = User.find_by(id: user_id)
    return if user.blank?

    PasswordResetMailer.password_reset(user).deliver_now
  end
end
