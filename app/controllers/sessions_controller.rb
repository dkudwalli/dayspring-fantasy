class SessionsController < ApplicationController
  RATE_LIMIT_STORE = Rails.application.config.x.auth_rate_limit_store

  unauthenticated_access_only only: %i[new create]
  rate_limit to: 10, within: 3.minutes, store: RATE_LIMIT_STORE, only: :create, with: -> {
    redirect_to new_session_path, alert: "Too many login attempts. Try again later."
  }

  def new
  end

  def create
    user = User.authenticate_by(email: params[:email].to_s.strip.downcase, password: params[:password])

    if user
      start_new_session_for(user)
      redirect_to after_authentication_url, notice: "Welcome back."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, notice: "You have been logged out.", status: :see_other
  end
end
