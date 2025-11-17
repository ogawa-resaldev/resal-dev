class MiscellaneousExpensesRequest < ApplicationRecord
  acts_as_paranoid
  belongs_to :user
  validates :occurrence_date, :amount, :direction, :status_id, :miscellaneous_expenses,
    presence: true
  validates :direction,
    inclusion: [1, 2]
  validates :status_id,
    inclusion: [0, 1, 2]
  validates :amount,
    numericality: { only_integer: true }

  scope :all_by_user, -> (user_id){
    user_role_id = User.find(user_id)[:user_role_id]
    case user_role_id
    # セラピスト
    when 1 then
      MiscellaneousExpensesRequest.where(user_id: user_id)
    # 管理者
    when 2 then
      MiscellaneousExpensesRequest.all
    # 内勤
    when 3 then
      MiscellaneousExpensesRequest.where(store_group_id: BackOfficeGroup.find_by(user_id:user_id)[:store_group_id])
    end
  }

  # キャッシュフローとの差分用。
  def is_request
    true
  end
  def highlite
    false
  end
  def note
    return ""
  end
  def type
    "雑費"
  end
  def type_detail
    self.read_attribute(:miscellaneous_expenses)
  end
end
