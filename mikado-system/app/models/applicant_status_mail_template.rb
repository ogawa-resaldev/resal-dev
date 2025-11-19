class ApplicantStatusMailTemplate < ApplicationRecord
  acts_as_paranoid
  belongs_to :store_group
  belongs_to :applicant_status
  belongs_to :applicant_mail_template

  scope :all_by_user, -> (user_id){
    user_role_id = User.find(user_id)[:user_role_id]
    case user_role_id
    # 管理者
    when 2 then
      ApplicantStatusMailTemplate.all
    # 内勤
    when 3 then
      ApplicantStatusMailTemplate.where(store_group_id: BackOfficeGroup.find_by(user_id:user_id)[:store_group_id])
    end
  }
end
