class CourseDetail < ApplicationRecord
  acts_as_paranoid
  belongs_to :course
end
