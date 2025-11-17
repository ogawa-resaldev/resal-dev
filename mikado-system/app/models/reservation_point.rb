class ReservationPoint < ApplicationRecord
  acts_as_paranoid
  belongs_to :reservation
  def self.sum_point
    self.all.map {|reservation_point|
      reservation_point.point
    }.sum
  end
  def self.sum_support_point
    self.all.map {|reservation_point|
    reservation_point.support_point
    }.sum
  end
end
