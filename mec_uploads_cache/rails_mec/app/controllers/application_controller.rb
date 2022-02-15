# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :null_session
  # このアクションを追加
  def after_sign_in_path_for(_resource)
    if current_user
      login_path(current_user.id)
    else
      new_user_session_path
    end
  end

  protected

  # 入力フォームからアカウント名情報をDBに保存するために追加
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
end
