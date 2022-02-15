# frozen_string_literal: true

class AddColumnToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :client_secret, :string
    add_column :users, :refresh_token, :string
    add_column :users, :expires_in, :string
    rename_column :users, :access_code, :access_token
  end
end
