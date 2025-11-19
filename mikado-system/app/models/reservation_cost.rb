class ReservationCost < ApplicationRecord
  acts_as_paranoid
  has_many :reservation_cost_details
end
