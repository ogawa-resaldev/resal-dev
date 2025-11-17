class PointDetail < ApplicationRecord
  acts_as_paranoid
  belongs_to :point
end
