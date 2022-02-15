# frozen_string_literal: true

class HomeController < ApplicationController
  def index; end

  def show
    @user = User.find_by(id: params[:id])
  end

  def update
    user = User.find_by(id: params[:id])
    upload_file = params[:user][:upload_file]
    if upload_file.present?
      upload_dir = Rails.root.join('public', 'user_files')
      upload_file_path = upload_dir + upload_file_name
      File.binwrite(upload_file_path, upload_file.read)
    end
  end
end
