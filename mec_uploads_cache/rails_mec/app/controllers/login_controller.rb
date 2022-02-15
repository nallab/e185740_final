# frozen_string_literal: true

class LoginController < ApplicationController
  def index; end

  def show
    @user = User.find_by(id: params[:id])
    home_path(params[:id]) if @user.client_id.present? && @user.access_token.present?
  end

  def update
    user = User.find_by(id: params[:id])
    user_param = params[:user]
    user.client_id = user_param[:client_id] if user_param[:client_id].present?
    user.client_secret = user_param[:client_secret] if user_param[:client_secret].present?
    if user_param[:access_token].present?
      @authenticator = DropboxApi::Authenticator.new(user.client_id, user.client_secret)
      @access_token = @authenticator.auth_code.get_token(user_param[:access_token])
      user.access_token = @access_token.token
      user.refresh_token = @access_token.refresh_token
      user.expires_in = (Time.zone.now + @access_token.expires_in).to_s
    end
    user.save!
  end
end
