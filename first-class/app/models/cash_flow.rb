class CashFlow < ApplicationRecord
  acts_as_paranoid
  belongs_to :user
  validates :occurrence_date, :cash_flow_period, :user_id, :amount, :direction,
    presence: true
  validates :direction,
    inclusion: [1, 2]
  validates :amount,
    numericality: { only_integer: true }

  scope :all_by_user, -> (user_id){
    user_role_id = User.find(user_id)[:user_role_id]
    case user_role_id
    # セラピスト
    when 1 then
      CashFlow.where(user_id: user_id)
    # 管理者
    when 2 then
      CashFlow.all
    # 内勤
    when 3 then
      CashFlow.where(store_group_id: BackOfficeGroup.find_by(user_id:user_id)[:store_group_id])
    end
  }

  def highlite
    # 支払い期限を過ぎている。
    if self.read_attribute(:cash_flow_period) < Date.current then
      return true
    else
      if self.read_attribute(:transfer_id) == nil && self.read_attribute(:reservation_id) != nil then
        reservation_payment_method_id = Reservation.find(self.read_attribute(:reservation_id)).reservation_payment_method_id
        # 5件以上溜まっている。
        condition1 = CashFlow.where(user_id: self.read_attribute(:user_id)).where.not(reservation_id: nil).where(transfer_id: nil).count > 5
        # 現金手渡しで、6日以上溜まっている。
        condition2 = reservation_payment_method_id == 1 && ((Time.current - self.read_attribute(:occurrence_date)) / (60 * 60 * 24)).floor  > 5
        return condition1 || condition2
      else
        return false
      end
    end
  end

  def note
    # 支払い期限を過ぎている。
    if self.read_attribute(:cash_flow_period) < Date.current then
      return "支払い期限を過ぎています。清算をお願いいたします。"
    else
      if self.read_attribute(:transfer_id) == nil && self.read_attribute(:reservation_id) != nil then
        reservation_payment_method_id = Reservation.find(self.read_attribute(:reservation_id)).reservation_payment_method_id
        # 現金手渡し以外で、10日より前。
        if reservation_payment_method_id != 1 then
          if ((Time.current - self.read_attribute(:occurrence_date)) / (60 * 60 * 24)).floor  < 10 then
            alow_date = self.read_attribute(:occurrence_date) + 10 * 60 * 60 * 24
            return alow_date.strftime("%Y/%m/%d") + "以降に清算可能です。(相殺には利用できます)"
          end
        end
      end
    end
    return ""
  end

  def type
    if self.read_attribute(:reservation_id) != nil then
      "予約"
    elsif self.read_attribute(:bar_sales_id) != nil then
      "バー"
    elsif self.read_attribute(:miscellaneous_expenses) != nil then
      "雑費"
    else
      "予期せぬ種別"
    end
  end

  def type_detail
    if self.read_attribute(:reservation_id) != nil then
      name = ""
      reservation = Reservation.find(self.read_attribute(:reservation_id))
      if reservation.present? then
        name = reservation.name
      end
      name
    elsif self.read_attribute(:bar_sales_id) != nil then
      ""
    elsif self.read_attribute(:miscellaneous_expenses) != nil then
      self.read_attribute(:miscellaneous_expenses)
    else
      ""
    end
  end

  # 雑費申請との差分用。
  def is_request
    false
  end
end
