class User < ApplicationRecord
  extend FriendlyId

  has_secure_password
  friendly_id :username, use: :slugged

  has_one_attached :avatar
end
