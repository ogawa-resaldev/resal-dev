class ApplicantAutoNotificationsController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: :index

  def index
    @title = "求人自動通知"
    @applicant_auto_notifications = ApplicantAutoNotification.all_by_user(session[:user_id])

    if flash[:applicant_auto_notification_id].present?
      @applicant_auto_notifications.each do |applicant_auto_notification|
        if applicant_auto_notification.id.to_s == flash[:applicant_auto_notification_id].to_s
          applicant_auto_notification.assign_attributes(flash[:applicant_auto_notification_params])
          applicant_auto_notification.valid?
        end
      end
    end

    # 新規作成用のapplicant_line_templateを初期化
    @new_applicant_auto_notification = ApplicantAutoNotification.new
    if flash[:new_applicant_auto_notification_params].present?
      @new_applicant_auto_notification.assign_attributes(flash[:new_applicant_auto_notification_params])
      @new_applicant_auto_notification.valid?
    end

    # 各種パラメータのselect
    # 対象日付
    @target_date_select = [["面接日", "interview_date"], ["研修日", "training_date"]]
    # 前日/当日/翌日
    @offset_days_select = [["前日", "-1"], ["当日", "0"], ["翌日", "1"]]
    # 通知時間
    @notification_time_select = (10..22).map { |h| ["#{h}:00", format("%02d00", h)] }
  end

  def create
    applicant_auto_notification = ApplicantAutoNotification.new(applicant_auto_notification_params)
    applicant_auto_notification.execute_flag = 1

    begin
      ActiveRecord::Base.transaction do
        applicant_auto_notification.save!
      end

      # うまく作成できたら、一覧に戻る。
      redirect_to("/applicant_auto_notifications")
    rescue ActiveRecord::RecordInvalid => e
      flash[:new_applicant_auto_notification_params] = applicant_auto_notification_params
      redirect_to("/applicant_auto_notifications")
    end
  end

  def update
    applicant_auto_notification = ApplicantAutoNotification.find(params[:id])
    begin
      ActiveRecord::Base.transaction do
        applicant_auto_notification.update!(applicant_auto_notification_params)
      end

      # うまく更新できたら、一覧に戻る。
      redirect_to("/applicant_auto_notifications")
    rescue ActiveRecord::RecordInvalid => e
      flash[:applicant_auto_notification_params] = applicant_auto_notification_params
      flash[:applicant_auto_notification_id] = params[:id]
      redirect_to("/applicant_auto_notifications")
    end
  end

  private def applicant_auto_notification_params
    params.require(:applicant_auto_notification).permit(
      :store_group_id,
      :execute_flag,
      :target_date,
      :offset_days,
      :notification_time,
      :applicant_mail_template_id,
      :applicant_line_template_id
    )
  end
end
