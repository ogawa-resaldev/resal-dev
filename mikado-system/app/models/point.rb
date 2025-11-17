class Point < ApplicationRecord
  acts_as_paranoid
  has_many :point_details
end
