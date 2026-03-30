class PasswordResetsController < ApplicationController
  RATE_LIMIT_STORE = Rails.application.config.x.auth_rate_limit_store

  before_action :set_user_from_token, only: %i[edit update]
  rate_limit to: 10, within: 3.minutes, store: RATE_LIMIT_STORE, only: :create, with: -> {
    redirect_to new_password_reset_path, alert: "Too many password reset attempts. Try again later."
  }

  def new
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    PasswordResetDeliveryJob.perform_later(user.id) if user.present?

    redirect_to new_session_path, notice: "If an account exists for that email, a reset link has been sent."
  end

  def edit
  end

  def update
    if @user.update(password_reset_params)
      terminate_session
      redirect_to new_session_path, notice: "Your password has been updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_user_from_token
    @user = User.find_by_token_for(:password_reset, params[:token])
    return if @user.present?

    redirect_to new_password_reset_path, alert: "That password reset link is invalid or has expired."
  end

  def password_reset_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
