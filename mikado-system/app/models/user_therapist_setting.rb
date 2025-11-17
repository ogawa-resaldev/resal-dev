class UserTherapistSetting < ApplicationRecord
  encrypts :mail_address
  encrypts :account_information
  acts_as_paranoid
  belongs_to :user
  belongs_to :rank, optional: true
  validates :new_face,
    inclusion: [true, false]
end
