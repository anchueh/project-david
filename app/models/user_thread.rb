# frozen_string_literal: true

class UserThread < ApplicationRecord
  validates :thread_id, presence: true, uniqueness: true
  validates :user_id, presence: true, uniqueness: true
end
