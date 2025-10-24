class ReservationCostDetail < ApplicationRecord
  acts_as_paranoid
  belongs_to :reservation_cost
end
