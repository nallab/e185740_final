# frozen_string_literal: true

class CreateTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :tokens do |t|
      t.string :uid
      t.string :token_type
      t.text   :scope
      t.text   :account_id
      t.text   :access_token
      t.text   :refresh_token
      t.integer :expires_at
      t.integer :user_id
      t.timestamps
    end
  end
end
