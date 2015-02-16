class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def log_in(user)
    session[:user_id] = user.id
  end

  def translate(key)
    I18n.translate("#{params[:controller]}.#{params[:action]}#{key}")
  end
end
