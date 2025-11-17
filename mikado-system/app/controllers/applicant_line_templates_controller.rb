class ApplicantLineTemplatesController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: :index

  def index
    @title = "求人LINEテンプレート一覧"
    @applicant_line_templates = ApplicantLineTemplate.all_by_user(session[:user_id])

    if flash[:applicant_line_template_id].present?
      @applicant_line_templates.each do |applicant_line_template|
        if applicant_line_template.id.to_s == flash[:applicant_line_template_id].to_s
          applicant_line_template.assign_attributes(flash[:applicant_line_template_params])
          applicant_line_template.valid?
        end
      end
    end

    # 新規作成用のapplicant_line_templateを初期化
    @new_applicant_line_template = ApplicantLineTemplate.new
    if flash[:new_applicant_line_template_params].present?
      @new_applicant_line_template.assign_attributes(flash[:new_applicant_line_template_params])
      @new_applicant_line_template.valid?
    end
  end

  def create
    applicant_line_template = ApplicantLineTemplate.new(applicant_line_template_params)

    begin
      ActiveRecord::Base.transaction do
        applicant_line_template.save!
      end

      # うまく作成できたら、一覧に戻る。
      redirect_to("/applicant_line_templates")
    rescue ActiveRecord::RecordInvalid => e
      flash[:new_applicant_line_template_params] = applicant_line_template_params
      redirect_to("/applicant_line_templates")
    end
  end

  def update
    applicant_line_template = ApplicantLineTemplate.find(params[:id])
    begin
      ActiveRecord::Base.transaction do
        applicant_line_template.update!(applicant_line_template_params)
      end

      # うまく更新できたら、一覧に戻る。
      redirect_to("/applicant_line_templates")
    rescue ActiveRecord::RecordInvalid => e
      flash[:applicant_line_template_params] = applicant_line_template_params
      flash[:applicant_line_template_id] = params[:id]
      redirect_to("/applicant_line_templates")
    end
  end

  private def applicant_line_template_params
    params.require(:applicant_line_template).permit(
      :store_group_id,
      :line_template_name,
      :line_template_body
    )
  end
end
