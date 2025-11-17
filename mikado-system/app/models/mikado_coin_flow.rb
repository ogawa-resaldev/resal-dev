class MikadoCoinFlow < ApplicationRecord
  acts_as_paranoid
  attr_accessor :register
  attr_accessor :direction_name
  belongs_to :user
  validates :reason, :direction, :coin,
    presence: true
  validates :coin,
    numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :direction,
    inclusion: [1, 2]
  validate :check_balance

  private def check_balance
    if self.read_attribute(:user_id).present? then
      mikado_coin_balance = UserTherapistSetting.find_by(user_id: self.read_attribute(:user_id))[:mikado_coin_balance]
      if self.read_attribute(:direction) == 2 && mikado_coin_balance < self.read_attribute(:coin) then
        self.errors.add(:base, '残高が不足しているため、出庫できません。(残高：' + mikado_coin_balance.to_s + ')')
      end
    end
  end

  # 入出庫申請との差分用。
  def is_request
    false
  end
end
