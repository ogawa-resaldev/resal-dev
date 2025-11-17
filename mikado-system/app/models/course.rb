class Course < ApplicationRecord
  acts_as_paranoid
  has_many :course_details
end
