class Transfer < ApplicationRecord
  acts_as_paranoid
  belongs_to :store_group
  belongs_to :user
  has_many :cash_flows, -> { order(:occurrence_date, :id) }
  validates :user_id, :transfer_deadline,
    presence: true
  validates :direction,
    inclusion: [1, 2]

  scope :all_by_user, -> (user_id){
    user_role_id = User.find(user_id)[:user_role_id]
    case user_role_id
    # セラピスト
    when 1 then
      Transfer.where(user_id: user_id)
    # 管理者
    when 2 then
      Transfer.all
    # 内勤
    when 3 then
      Transfer.where(store_group_id: BackOfficeGroup.find_by(user_id:user_id)[:store_group_id])
    end
  }

  def sum_cash_flows
    # 方向が1(セラピスト→店)を正として計算。
    sum_amount = 0
    cash_flows = CashFlow.where(transfer_id: self.read_attribute(:id))
    cash_flows.each do |cash_flow|
      if cash_flow.direction == 1 then
        sum_amount += cash_flow.amount
      else
        sum_amount -= cash_flow.amount
      end
    end
    if sum_amount < 0 then
      return {amount: -1 * sum_amount, direction: 2}
    else
      return {amount: sum_amount, direction: 1}
    end
  end

  def highlite
    self.read_attribute(:transfer_deadline) < Time.current && self.read_attribute(:transfer_date) == nil && self.read_attribute(:confirmation_flag) == false
  end

  def is_rejectable
    false
    if self.direction == 2 && self.transfer_amount == nil then
      true
    end
  end
end
