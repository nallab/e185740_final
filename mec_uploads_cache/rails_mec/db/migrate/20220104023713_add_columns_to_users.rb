# frozen_string_literal: true

class AddColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :client_id, :string
    add_column :users, :access_code, :string
  end
end
