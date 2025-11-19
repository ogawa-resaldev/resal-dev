class ReservationCourse < ApplicationRecord
  acts_as_paranoid
  belongs_to :reservation
  validates :duration, :amount, :back_therapist_amount,
    presence: true

  def self.sum_amount
    self.all.map {|reservation_courses|
    reservation_courses.amount
    }.sum
  end
  def self.sum_back_therapist_amount
    self.all.map {|reservation_courses|
    reservation_courses.back_therapist_amount
    }.sum
  end
  def self.sum_duration
    self.all.map {|reservation_courses|
    reservation_courses.duration
    }.sum
  end
end
