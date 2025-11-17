class ApplicantAutoNotification < ApplicationRecord
  acts_as_paranoid
  belongs_to :store_group
  belongs_to :applicant_mail_template, optional: true
  belongs_to :applicant_line_template, optional: true

  scope :all_by_user, -> (user_id){
    user_role_id = User.find(user_id)[:user_role_id]
    case user_role_id
    # 管理者
    when 2 then
      ApplicantAutoNotification.all
    # 内勤
    when 3 then
      store_group_id = BackOfficeGroup.find_by(user_id: user_id)[:store_group_id]
      ApplicantAutoNotification.where(store_group_id: store_group_id)
    end
  }

  def target_date_text
    case self.read_attribute(:target_date)
    when "interview_date" then
      return "面接日"
    when "training_date" then
      return "研修日"
    else
      return ""
    end
  end

  def offset_days_text
    case self.read_attribute(:offset_days)
    when -1 then
      return "前日"
    when 0 then
      return "当日"
    when 1 then
      return "翌日"
    else
      return ""
    end
  end

  def notification_time_text
    time = self.read_attribute(:notification_time)
    return "" if time.blank? || time.length != 4
    "#{time[0..1]}:#{time[2..3]}"
  end
end
