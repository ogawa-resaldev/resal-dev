class BackOfficeGroup < ApplicationRecord
  acts_as_paranoid
  belongs_to :user
  belongs_to :store_group
end
