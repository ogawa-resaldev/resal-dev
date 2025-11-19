class MikadoCoinFlowRequest < ApplicationRecord
  acts_as_paranoid
  belongs_to :user
  validates :reason, :direction, :coin,
    presence: true
  validates :coin,
    numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :direction,
    inclusion: [1, 2]
  validate :check_balance

  private def check_balance
    mikado_coin_balance = UserTherapistSetting.find_by(user_id: self.read_attribute(:user_id))[:mikado_coin_balance]
    if self.read_attribute(:direction) == 2 && mikado_coin_balance < self.read_attribute(:coin) then
      self.errors.add(:base, '残高が不足しているため、出庫申請できません。(残高：' + mikado_coin_balance.to_s + ')')
    end
  end

  # 通常の入出庫との差分用。
  def is_request
    true
  end
end
