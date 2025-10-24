class ApplicantMailTemplatesController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: :index

  def index
    @title = "求人メールテンプレート一覧"
    @applicant_mail_templates = ApplicantMailTemplate.all_by_user(session[:user_id])

    if flash[:applicant_mail_template_id].present?
      @applicant_mail_templates.each do |applicant_mail_template|
        if applicant_mail_template.id.to_s == flash[:applicant_mail_template_id].to_s
          applicant_mail_template.assign_attributes(flash[:applicant_mail_template_params])
          applicant_mail_template.valid?
        end
      end
    end

    # 新規作成用のapplicant_mail_templateを初期化
    @new_applicant_mail_template = ApplicantMailTemplate.new
    if flash[:new_applicant_mail_template_params].present?
      @new_applicant_mail_template.assign_attributes(flash[:new_applicant_mail_template_params])
      @new_applicant_mail_template.valid?
    end
  end

  def create
    applicant_mail_template = ApplicantMailTemplate.new(applicant_mail_template_params)

    begin
      ActiveRecord::Base.transaction do
        applicant_mail_template.save!
      end

      # うまく作成できたら、一覧に戻る。
      redirect_to("/applicant_mail_templates")
    rescue ActiveRecord::RecordInvalid => e
      flash[:new_applicant_mail_template_params] = applicant_mail_template_params
      redirect_to("/applicant_mail_templates")
    end
  end

  def update
    applicant_mail_template = ApplicantMailTemplate.find(params[:id])
    begin
      ActiveRecord::Base.transaction do
        applicant_mail_template.update!(applicant_mail_template_params)
      end

      # うまく更新できたら、一覧に戻る。
      redirect_to("/applicant_mail_templates")
    rescue ActiveRecord::RecordInvalid => e
      flash[:applicant_mail_template_params] = applicant_mail_template_params
      flash[:applicant_mail_template_id] = params[:id]
      redirect_to("/applicant_mail_templates")
    end
  end

  private def applicant_mail_template_params
    params.require(:applicant_mail_template).permit(
      :store_group_id,
      :mail_template_name,
      :mail_template_subject,
      :mail_template_body
    )
  end
end
