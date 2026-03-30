module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :user_signed_in?
  end

  class_methods do
    def unauthenticated_access_only(**options)
      before_action :redirect_if_authenticated, **options
    end
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_user!
    return if user_signed_in?

    store_authentication_location
    redirect_to new_session_path, alert: "Please log in to continue."
  end

  def authenticate_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: "Admin access only."
  end

  def start_new_session_for(user)
    return_to = session[:return_to_after_authenticating]

    reset_session
    session[:user_id] = user.id
    session[:return_to_after_authenticating] = return_to if return_to.present?
    @current_user = user
  end

  def terminate_session
    reset_session
    @current_user = nil
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_path
  end

  def redirect_if_authenticated
    redirect_to root_path if user_signed_in?
  end

  def store_authentication_location
    return unless request.get?

    session[:return_to_after_authenticating] = request.original_url
  end
end
