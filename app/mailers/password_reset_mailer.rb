class PasswordResetMailer < ApplicationMailer
  def password_reset(user)
    @user = user
    @reset_url = edit_password_reset_url(user.generate_token_for(:password_reset))

    mail(to: user.email, subject: "Reset your Dayspring IPL Prediction password")
  end
end
