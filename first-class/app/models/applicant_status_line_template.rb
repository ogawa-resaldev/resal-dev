class ApplicantStatusLineTemplate < ApplicationRecord
  acts_as_paranoid
  belongs_to :store_group
  belongs_to :applicant_status
  belongs_to :applicant_line_template

  scope :all_by_user, -> (user_id){
    user_role_id = User.find(user_id)[:user_role_id]
    case user_role_id
    # 管理者
    when 2 then
      ApplicantStatusLineTemplate.all
    # 内勤
    when 3 then
      ApplicantStatusLineTemplate.where(store_group_id: BackOfficeGroup.find_by(user_id:user_id)[:store_group_id])
    end
  }
end
