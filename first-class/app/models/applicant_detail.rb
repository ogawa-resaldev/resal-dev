class ApplicantDetail < ApplicationRecord
  encrypts :name, :tel, :mail_address
  acts_as_paranoid
  belongs_to :applicant
  belongs_to :preferred_store, class_name: "Store"
  validates :name, :mail_address, :tel, :application_date, :age, :height, :weight, :nearest_station, :education, :occupation, :work_frequency, :experience_count, :smoking, :has_tattoo, :therapist_experience, :mosaic, :how_to_know,
    presence: true
end
