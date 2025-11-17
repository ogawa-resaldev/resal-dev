class BonusPoint < ApplicationRecord
  acts_as_paranoid
  attr_accessor :register, :store_group_name
  belongs_to :user
  belongs_to :store_group
  validates :occurrence_date, :point, :support_point,
    presence: true
  validates :point, :support_point,
    numericality: true

  scope :all_by_user, -> (user_id){
    user_role_id = User.find(user_id)[:user_role_id]
    case user_role_id
    # セラピスト
    when 1 then
      BonusPoint.where(user_id: user_id)
    # 管理者
    when 2 then
      BonusPoint.all
    # 内勤
    when 3 then
      BonusPoint.where(store_group_id: BackOfficeGroup.find_by(user_id:user_id)[:store_group_id])
    end
  }
end
