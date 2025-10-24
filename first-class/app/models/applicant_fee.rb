class ApplicantFee < ApplicationRecord
  acts_as_paranoid
  belongs_to :applicant
  validates :fee_name, :amount,
    presence: true
end
