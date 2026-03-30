class RegistrationsController < ApplicationController
  RATE_LIMIT_STORE = Rails.application.config.x.auth_rate_limit_store

  unauthenticated_access_only
  rate_limit to: 10, within: 3.minutes, store: RATE_LIMIT_STORE, only: :create, with: -> {
    redirect_to new_registration_path, alert: "Too many sign-up attempts. Try again later."
  }

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for(@user)
      redirect_to after_authentication_url, notice: "Your account has been created."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
