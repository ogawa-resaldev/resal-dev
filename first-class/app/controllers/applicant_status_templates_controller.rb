class ApplicantStatusTemplatesController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: :index

  def index
    @title = "ステータス別テンプレート"
    # 選考中以外のステータスを対象とする。
    @applicant_statuses = ApplicantStatus.where.not(id: 1)

    @applicant_status_templates = {}
    applicant_status_tmp = {}
    ApplicantStatus.all.each do |applicant_status|
      applicant_status_tmp[applicant_status.id] = {
        mail:[],
        line:[]
      }
    end
    StoreGroup.all_by_user(session[:user_id]).each do |store_group|
      @applicant_status_templates[store_group.id] = applicant_status_tmp.deep_dup
    end

    # メールテンプレートを追加。
    @applicant_status_mail_templates = ApplicantStatusMailTemplate.all_by_user(session[:user_id])
    @applicant_status_mail_templates.each do |applicant_status_mail_template|
      @applicant_status_templates[applicant_status_mail_template.store_group_id][applicant_status_mail_template.applicant_status_id][:mail].push({
        id:applicant_status_mail_template.id,
        name:applicant_status_mail_template.applicant_mail_template.mail_template_name,
        subject:applicant_status_mail_template.applicant_mail_template.mail_template_subject,
        body:applicant_status_mail_template.applicant_mail_template.mail_template_body,
        default_flag:applicant_status_mail_template.default_flag
      })
    end
    # LINEテンプレートを追加。
    @applicant_status_line_templates = ApplicantStatusLineTemplate.all_by_user(session[:user_id])
    @applicant_status_line_templates.each do |applicant_status_line_template|
      @applicant_status_templates[applicant_status_line_template.store_group_id][applicant_status_line_template.applicant_status_id][:line].push({
        id:applicant_status_line_template.id,
        name:applicant_status_line_template.applicant_line_template.line_template_name,
        body:applicant_status_line_template.applicant_line_template.line_template_body,
        default_flag:applicant_status_line_template.default_flag
      })
    end

    # メールテンプレート選択
    @applicant_mail_templates = {}
    ApplicantMailTemplate.all_by_user(session[:user_id]).each do |applicant_mail_template|
      if !@applicant_mail_templates.has_key?(applicant_mail_template.store_group_id) then
        @applicant_mail_templates[applicant_mail_template.store_group_id] = []
      end
      @applicant_mail_templates[applicant_mail_template.store_group_id].push({
        id: applicant_mail_template.id,
        name: applicant_mail_template.mail_template_name,
        subject: applicant_mail_template.mail_template_subject,
        body: applicant_mail_template.mail_template_body
      })
    end
    # LINEテンプレート選択
    @applicant_line_templates = {}
    ApplicantLineTemplate.all_by_user(session[:user_id]).each do |applicant_line_template|
      if !@applicant_line_templates.has_key?(applicant_line_template.store_group_id) then
        @applicant_line_templates[applicant_line_template.store_group_id] = []
      end
      @applicant_line_templates[applicant_line_template.store_group_id].push({
        id: applicant_line_template.id,
        name: applicant_line_template.line_template_name,
        body: applicant_line_template.line_template_body
      })
    end
  end

  def add_line_template
    applicant_status_line_template = ApplicantStatusLineTemplate.new(
      store_group_id: params[:store_group_id],
      applicant_status_id: params[:applicant_status_id],
      applicant_line_template_id: params[:applicant_line_template_id]
    )

    # もし追加した以外にテンプレートがなければデフォルトとして登録。
    if ApplicantStatusLineTemplate.where(store_group_id: params[:store_group_id], applicant_status_id: params[:applicant_status_id]).count == 0 then
      applicant_status_line_template.default_flag = 1
    end
    applicant_status_line_template.save!

    redirect_to("/applicant_status_templates")
  end

  def add_mail_template
    applicant_status_mail_template = ApplicantStatusMailTemplate.new(
      store_group_id: params[:store_group_id],
      applicant_status_id: params[:applicant_status_id],
      applicant_mail_template_id: params[:applicant_mail_template_id]
    )

    # もし追加した以外にテンプレートがなければデフォルトとして登録。
    if ApplicantStatusMailTemplate.where(store_group_id: params[:store_group_id], applicant_status_id: params[:applicant_status_id]).count == 0 then
      applicant_status_mail_template.default_flag = 1
    end
    applicant_status_mail_template.save!

    redirect_to("/applicant_status_templates")
  end

  def line_default
    target = ApplicantStatusLineTemplate.find(params[:id])
    begin
      ActiveRecord::Base.transaction do
        ApplicantStatusLineTemplate.where(store_group_id: target.store_group_id, applicant_status_id: target.applicant_status_id).each do |applicant_status_line_template|
          applicant_status_line_template.default_flag = 0
          applicant_status_line_template.save!
        end

        target.default_flag = 1
        target.save!

        # うまく作成できたら、一覧に飛ぶ。
        redirect_to("/applicant_status_templates")
      end
    rescue ActiveRecord::RecordInvalid => e
      redirect_to("/applicant_status_templates")
    end
  end

  def mail_default
    target = ApplicantStatusMailTemplate.find(params[:id])
    begin
      ActiveRecord::Base.transaction do
        ApplicantStatusMailTemplate.where(store_group_id: target.store_group_id, applicant_status_id: target.applicant_status_id).each do |applicant_status_mail_template|
          applicant_status_mail_template.default_flag = 0
          applicant_status_mail_template.save!
        end

        target.default_flag = 1
        target.save!

        # うまく作成できたら、一覧に飛ぶ。
        redirect_to("/applicant_status_templates")
      end
    rescue ActiveRecord::RecordInvalid => e
      redirect_to("/applicant_status_templates")
    end
  end

  def line_destroy
    applicantStatusLineTemplate = ApplicantStatusLineTemplate.find(params[:id])
    storeGroupId = applicantStatusLineTemplate.store_group_id
    applicantStatusId = applicantStatusLineTemplate.applicant_status_id
    defaultFlag = applicantStatusLineTemplate.default_flag
    applicantStatusLineTemplate.delete

    # もしデフォルトのテンプレートを削除した場合、残ったものの一番上をデフォルトにする。
    if defaultFlag then
      sameIds = ApplicantStatusLineTemplate.where(store_group_id:storeGroupId, applicant_status_id:applicantStatusId)
      if sameIds then
        sameIds[0].update!(default_flag: 1)
      end
    end

    redirect_to(request.referer)
  end

  def mail_destroy
    applicantStatusMailTemplate = ApplicantStatusMailTemplate.find(params[:id])
    storeGroupId = applicantStatusMailTemplate.store_group_id
    applicantStatusId = applicantStatusMailTemplate.applicant_status_id
    defaultFlag = applicantStatusMailTemplate.default_flag
    applicantStatusMailTemplate.delete

    # もしデフォルトのテンプレートを削除した場合、残ったものの一番上をデフォルトにする。
    if defaultFlag then
      sameIds = ApplicantStatusMailTemplate.where(store_group_id:storeGroupId, applicant_status_id:applicantStatusId)
      if sameIds then
        sameIds[0].update!(default_flag: 1)
      end
    end

    redirect_to(request.referer)
  end
end
