class ApplicantMailTemplate < ApplicationRecord
  acts_as_paranoid
  belongs_to :store_group
  validates :mail_template_name,
    uniqueness: { scope: :store_group_id }
  validates :mail_template_name,
    presence: true
  scope :all_by_user, -> (user_id){
    user_role_id = User.find(user_id)[:user_role_id]
    case user_role_id
    # 管理者
    when 2 then
      ApplicantMailTemplate.all
    # 内勤
    when 3 then
      store_group_id = BackOfficeGroup.find_by(user_id: user_id)[:store_group_id]
      ApplicantMailTemplate.where(store_group_id: store_group_id)
    end
  }
end
