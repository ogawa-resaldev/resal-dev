class Applicant < ApplicationRecord
  encrypts :notification_group_id
  acts_as_paranoid
  belongs_to :applicant_status
  belongs_to :interviewer, class_name: "User", optional: true
  belongs_to :applicant_store, class_name: "Store", optional: true
  has_one :applicant_detail
  accepts_nested_attributes_for :applicant_detail, allow_destroy: true
  has_many :applicant_fees
  accepts_nested_attributes_for :applicant_fees, allow_destroy: true
  validate :check_update_params

  scope :all_by_user, -> (user_id){
    user_role_id = User.find(user_id)[:user_role_id]
    case user_role_id
    # 管理者
    when 2 then
      Applicant.all
    # 内勤
    when 3 then
      store_ids = Store.where(store_group_id: BackOfficeGroup.find_by(user_id: user_id)[:store_group_id]).pluck(:id)
      Applicant.joins(:applicant_detail).where(applicant_details: { preferred_store_id: store_ids })
    end
  }

  def training_adjustment
    case self.read_attribute(:training_adjustment_id)
    when 1 then
      return "調整中"
    when 2 then
      return "調整済み"
    end
  end

  def shooting_adjustment
    case self.read_attribute(:shooting_adjustment_id)
    when 1 then
      return "調整中"
    when 2 then
      return "調整済み"
    end
  end

  private def check_update_params
    case self.read_attribute(:applicant_status_id)
    when 3 then
      # 講師調整中にする場合、面接日と面接担当者を決めておく必要がある。
      if !self.read_attribute(:interviewer_id).present? then
        self.errors.add(:base, 'ステータスを「' + ApplicantStatus.find(self.read_attribute(:applicant_status_id)).status_name + '」に変更するには、面接担当者を選択している必要があります。')
      end
      if !self.read_attribute(:interview_datetime).present? then
        self.errors.add(:base, 'ステータスを「' + ApplicantStatus.find(self.read_attribute(:applicant_status_id)).status_name + '」に変更するには、面接日時を設定している必要があります。')
      end
    when 4 then
      # 研修準備中にする場合、研修調整済み、撮影調整済みにしておく必要がある。
      if self.read_attribute(:training_adjustment_id) != 2 then
        self.errors.add(:base, 'ステータスを「' + ApplicantStatus.find(self.read_attribute(:applicant_status_id)).status_name + '」に変更するには、研修が調整済みになっている必要があります。')
      end
      if self.read_attribute(:shooting_adjustment_id) != 2 then
        self.errors.add(:base, 'ステータスを「' + ApplicantStatus.find(self.read_attribute(:applicant_status_id)).status_name + '」に変更するには、撮影が調整済みになっている必要があります。')
      end
    when 6 then
      # デビュー済みにする場合、以下が必要。
      # 源氏名を決めていること。
      # 全ての費用に受け取り日が設定されていること。
      if !self.read_attribute(:professional_name).present? then
        self.errors.add(:base, 'ステータスを「' + ApplicantStatus.find(self.read_attribute(:applicant_status_id)).status_name + '」に変更するには、源氏名を設定している必要があります。')
      end
      self.applicant_fees.each do |applicant_fee|
        if !applicant_fee[:receive_date].present? then
          self.errors.add(:base, 'ステータスを「' + ApplicantStatus.find(self.read_attribute(:applicant_status_id)).status_name + '」に変更するには、全ての費用で受け取り日を設定している必要があります。')
          break;
        end
      end
    end
  end

  def save_uploaded_file(name, file)
    # ファイル名を生成（タイムスタンプ + 元のファイル名）
    filename = "#{Time.current.to_i}_#{file.original_filename}"
    # 保存先のパスを生成
    path = Rails.root.join('public', 'uploads', 'applicants', filename)
    # ファイルを保存
    File.binwrite(path, file.read)
    # モデルの属性を更新
    self.applicant_detail["#{name}_path"] = "/uploads/applicants/#{filename}"

    # データベースに保存
    save!
  end
end
