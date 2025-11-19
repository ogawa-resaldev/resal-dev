class UserRank < ApplicationRecord
  acts_as_paranoid
  attr_accessor :register_user
  belongs_to :user
  belongs_to :rank
end
