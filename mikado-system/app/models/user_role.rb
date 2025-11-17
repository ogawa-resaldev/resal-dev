class UserRole < ApplicationRecord
  acts_as_paranoid

  scope :all_by_user, -> (user_id){
    user_role_id = User.find(user_id)[:user_role_id]
    case user_role_id
    # 管理者
    when 2 then
      UserRole.all
    # 内勤
    when 3 then
      UserRole.where(id: [1,3])
    end
  }
end
