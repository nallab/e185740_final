# frozen_string_literal: true

class Post < ApplicationRecord
  has_one_attached :file
  belongs_to :user
end
