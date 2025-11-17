class ReservationFee < ApplicationRecord
  acts_as_paranoid
  belongs_to :reservation
  validates :amount, :back_therapist_amount,
    presence: true

  def self.sum_amount
    self.all.map {|reservation_fees|
      reservation_fees.amount
    }.sum
  end
  def self.sum_back_therapist_amount
    self.all.map {|reservation_fees|
      reservation_fees.back_therapist_amount
    }.sum
  end
end
