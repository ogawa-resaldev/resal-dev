class Reservation < ApplicationRecord
  encrypts :name, :tel, :mail_address
  acts_as_paranoid
  has_many :reservation_points
  accepts_nested_attributes_for :reservation_points, allow_destroy: true
  has_many :reservation_fees
  accepts_nested_attributes_for :reservation_fees, allow_destroy: true
  has_many :reservation_courses
  accepts_nested_attributes_for :reservation_courses, allow_destroy: true
  belongs_to :reservation_payment_method
  belongs_to :reservation_status
  belongs_to :reservation_type
  belongs_to :store
  validates :reservation_datetime, :name, :contact_method, :meeting_count, :call_count, :tel, :mail_address, :place, :reservation_courses,
    presence: true
  validates :adjustment_flag, :paid_flag,
    inclusion: [true, false]
  validate :check_update_status, :check_fees_and_courses

  scope :all_by_user, -> (user_id){
    user_role_id = User.find(user_id)[:user_role_id]
    reservations = Reservation.all
    case user_role_id
    # セラピスト
    when 1 then
      # 最初のwhereだけ異なるので判定。
      is_first_filter = true
      userTherapists = UserTherapist.where(user_id: user_id)
      userTherapists.each_with_index do |user_therapist, index|
        if is_first_filter then
          reservations = reservations.where(store_id: user_therapist.store_id, therapist_id: user_therapist.therapist_id)
          is_first_filter = false
        else
          reservations = reservations.or(Reservation.where(store_id: user_therapist.store_id, therapist_id: user_therapist.therapist_id))
        end
      end
      reservations
    # 管理者
    when 2 then
      reservations
    # 内勤
    when 3 then
      store_id_list = Store.where(store_group_id: BackOfficeGroup.find_by(user_id:user_id)[:store_group_id]).pluck(:id)
      reservations.where(store_id: store_id_list)
    end
  }

  def therapist_name
    require 'uri'
    require 'net/http'
    require 'json'
    if !self.read_attribute(:store_id).blank? && !self.read_attribute(:therapist_id).blank? then
      uri = URI.parse(Store.find(self.read_attribute(:store_id)).store_url + 'wp-json/wp/v2/casts/' + self.read_attribute(:therapist_id).to_s)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      response = JSON.load(http.get(uri).body)
      if response.key?("title") then
        return response["title"]["rendered"]
      end
    end
    return ""
  end

  def highlite_unsettled
    # 予約開始時間を過ぎているのに、未確定。
    if (Time.current - self.read_attribute(:reservation_datetime)) > 0 && self.read_attribute(:reservation_status_id) == 1 then
      return "予約時間を過ぎていますが、未確定です。"
    end
    return ""
  end

  def highlite_expired
    # 予約日を過ぎたのに、遂行済もしくはキャンセルになっていない。
    if ((Time.current - self.read_attribute(:reservation_datetime)) / (60 * 60 * 24)).floor  > 0 && self.read_attribute(:reservation_status_id) != 3 && self.read_attribute(:reservation_status_id) != 4 then
      return "予約日を過ぎましたが、遂行済もしくはキャンセルになっていません。"
    end
    return ""
  end

  def highlite_payment
    # 24時間以内の遂行で、事前決済が確認できていないもの(遂行済み、キャンセルになっていないもの)
    if self.read_attribute(:reservation_payment_method_id) != 1 && self.read_attribute(:reservation_status_id) != 3 && self.read_attribute(:reservation_status_id) != 4 then
      if ((Time.current - self.read_attribute(:reservation_datetime)) / (60 * 60 * 24)).floor > -2 && !self.read_attribute(:paid_flag) then
        return "予約まで24時間を過ぎましたが、事前決済が確認できていません。"
      end
    end
    return ""
  end

  private def check_update_status
    # 確定もしくは遂行済みにする場合、セラピストを紐づけておく必要がある。
    if self.read_attribute(:reservation_status_id) == 2 || self.read_attribute(:reservation_status_id) == 4 then
      if !self.read_attribute(:therapist_id).present? then
        self.errors.add(:base, 'ステータスを「' + ReservationStatus.find(self.read_attribute(:reservation_status_id)).status_name + '」に変更するには、セラピストを選択している必要があります。')
      else
        user_therapist = UserTherapist.where(store_id: self.read_attribute(:store_id), therapist_id: self.read_attribute(:therapist_id))
        if !user_therapist.present? then
          self.errors.add(:base, 'ステータスを「' + ReservationStatus.find(self.read_attribute(:reservation_status_id)).status_name + '」に変更するには、対象のセラピストをユーザーに紐づける必要があります。')
        end
      end
    end
    # 事前決済系を遂行済みにする場合、支払い済みフラグが立っている必要がある。
    if self.read_attribute(:reservation_payment_method_id) != 1 && self.read_attribute(:reservation_status_id) == 4 then
      if !self.read_attribute(:paid_flag) then
        self.errors.add(:base, ReservationPaymentMethod.find(self.read_attribute(:reservation_payment_method_id)).payment_method + 'の予約のステータスを「' + ReservationStatus.find(self.read_attribute(:reservation_status_id)).status_name + '」に変更するには、支払い済みにしている必要があります。')
      end
    end
  end

  private def check_fees_and_courses
    # 割引対象外のコースしかない場合は、ここがfalseのまま。
    # 割引対象外：応援、デートコース、通話
    eligible_for_discount = false
    self.reservation_courses.each do |reservation_course|
      if reservation_course[:course_detail] == "応援" then
        self.errors.add(:base, '応援コースの金額は0円として、予約費用にて応援ポイントを選択してください。') if reservation_course[:amount] != 0
      elsif reservation_course[:course] != "デートコース" && reservation_course[:course] != "通話コース" then
        eligible_for_discount = true
      end
    end

    if !eligible_for_discount then
      self.reservation_fees.each do |reservation_fee|
        if reservation_fee[:fee_type] == "割引" then
          self.errors.add(:base, '割引対象外のコースに対して、割引を適用しようとしています。')
        end
      end
    end
  end
end
