class ApplicantsController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: [:new, :index, :edit]
  before_action :set_applicant_select_options, only: [:new, :edit]

  def new
    require 'uri'
    require 'net/http'
    require 'json'

    @title = "応募者登録"

    @applicant = Applicant.new
    @applicant.build_applicant_detail

    if flash[:applicant_params].present?
      @applicant.assign_attributes(flash[:applicant_params])
      @applicant.applicant_status_id = 1
      @applicant.valid?
    end

    # 希望の所属店舗選択
    @preferred_store_list = []
    uri = URI.parse(ENV["GET_APPLICANT_PREFERRED_STORES_API"])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"
    response = JSON.load(http.get(uri).body)
    response.each do |res|
      @preferred_store_list.push([res["store_name"], res["store_name"], {"data-id":res["system_store_id"]}])
    end
  end

  def create
    @applicant = Applicant.new(applicant_params)
    @applicant.applicant_status_id = 1

    begin
      ActiveRecord::Base.transaction do
        @applicant.save!

        # うまく作成できたら、一覧に飛ぶ。
        redirect_to("/applicants")
      end
    rescue ActiveRecord::RecordInvalid => e
      flash[:applicant_params] = applicant_params
      redirect_to "/applicants/new"
    end
  end

  def index
    @applicants = Applicant.all_by_user(session[:user_id]).order(:pending_flag, :applicant_status_id, :id)
    # 店舗グループによる絞り込み。
    if params[:store_group_id].present? then
      store_ids = Store.where(store_group_id: params[:store_group_id]).pluck(:id)
      @applicants = @applicants.joins(:applicant_detail).where(applicant_details: { preferred_store_id: store_ids })
    end
    # ステータスによる絞り込み。
    if !params[:sum_status_bits].present? then
      # 最初の表示の時だけここに来る想定。
      @applicants = @applicants.where(applicant_status_id: [1, 2, 3, 4, 5])
    else
      status_list = (0..10).select { |i| params[:sum_status_bits].to_i & (1 << i) > 0 }.map { |i| i + 1 }
      @applicants = @applicants.where(applicant_status_id: status_list)
    end
  end

  def edit
    @title = "応募者編集"

    @applicant = Applicant.find(params[:id])
    @beforeApplicantStatusId = @applicant.applicant_status_id
    if flash[:applicant_params_key] != nil then
      @applicant.assign_attributes(Rails.cache.read(flash[:applicant_params_key]))
      # 復元直後にキャッシュを削除
      Rails.cache.delete(flash[:applicant_params_key])
      @applicant.valid?
      @applicant.assign_attributes(applicant_status_id: @beforeApplicantStatusId)
    end

    @user = User.new()
    @initial_unlinked_therapist = ""
    @initial_applicant_login_id = ""
    @initial_applicant_auto_complete = ""
    if flash[:create_therapist_user_flag] then
      @user.assign_attributes(flash[:create_therapist_user_params]["user_params"])
      @user.build_user_therapist_setting(flash[:create_therapist_user_params]["user_therapist_setting_params"])
      @user.user_therapists.build(flash[:create_therapist_user_params]["user_therapist_params"])
      @user.valid?

      @initial_applicant_login_id = flash[:create_therapist_user_params]["applicant_login_id"]
      @initial_applicant_auto_complete = flash[:create_therapist_user_params]["applicant_auto_complete"]
    end

    # 応募者ステータスのセレクトリスト
    @status_select = []
    statuses = ApplicantStatus.all
    statuses.each do |status|
      if status.id == @beforeApplicantStatusId - 1 || status.id == @beforeApplicantStatusId || status.id == @beforeApplicantStatusId + 1 || status.id == 7 then
        @status_select.push([status.status_name, status.id])
      end
    end

    # 応募者メールテンプレートのセレクトリスト
    @mail_template_select = [{text:"選択なし", value:"未選択", subject:"", body:""}]
    store_group_id = @applicant.applicant_detail.preferred_store.store_group.id
    applicant_mail_templates = ApplicantMailTemplate.where(store_group_id: store_group_id)
    applicant_mail_templates.each do |applicant_mail_template|
      @mail_template_select.push({
        text: applicant_mail_template.mail_template_name,
        value: applicant_mail_template.mail_template_name,
        subject: applicant_mail_template.mail_template_subject,
        body: applicant_mail_template.mail_template_body
      })
    end

    # 応募者LINEテンプレートのセレクトリスト
    @line_template_select = [{text:"選択なし", value:"未選択", body:""}]
    store_group_id = @applicant.applicant_detail.preferred_store.store_group.id
    applicant_line_templates = ApplicantLineTemplate.where(store_group_id: store_group_id)
    applicant_line_templates.each do |applicant_line_template|
      @line_template_select.push({
        text: applicant_line_template.line_template_name,
        value: applicant_line_template.line_template_name,
        body: applicant_line_template.line_template_body
      })
    end

    # 面接担当者のセレクトリスト
    @interviewer_select = []
    users = User.all_by_user(session[:user_id])
    users.each do |user|
      if user.user_role_id != 1 then
       @interviewer_select.push([user.name, user.id])
      end
    end

    # デビュー時の選択セラピストのリスト
    @unlinked_therapist_select = [["未選択", ""]]
    if @beforeApplicantStatusId == 5 then
      # 全セラピスト情報を取得
      therapists = get_therapist_list

      # 既に紐づけられているセラピストのIDリスト
      linked_therapist_ids = []
      UserTherapist.where(store_id: @applicant.applicant_detail.preferred_store_id).each do |user_therapist|
        linked_therapist_ids.push(user_therapist[:therapist_id])
      end

      # 未連携のセラピストのみをフィルタリング
      therapists.each do |store_id, store_data|
        if store_id == @applicant.applicant_detail.preferred_store_id then
          store_data[:therapist].each do |therapist_id, therapist_data|
            if not linked_therapist_ids.include?(therapist_id) then
              @unlinked_therapist_select.push([therapist_data[:name], therapist_id])
            end
          end
        end
      end
    end

    # ステータス変更可能かどうかのフラグ。応募者の種々パラメータの変更可否判定に使用。
    @change_status_flag = @applicant.applicant_status_id < 6
  end

  def update
    @applicant = Applicant.find(params[:id])

    beforeApplicantStatusId = @applicant.applicant_status_id
    # デビュー済みにする際、ユーザーを作成するflagがonであればcreate_therapist_user系のflashを保持。
    if params[:create_therapist_user_flag] then
      flash[:create_therapist_user_params] = {
        applicant_login_id:params[:applicant][:applicant_login_id],
        applicant_auto_complete:params[:applicant][:applicant_auto_complete],
        applicant_therapist_id:params[:applicant][:applicant_therapist_id]
      }
    end

    begin
      ActiveRecord::Base.transaction do
        @applicant.update!(applicant_params)
        # 面接準備への遷移の場合、pass_classification系の更新
        afterApplicantStatusId = @applicant.applicant_status_id
        if beforeApplicantStatusId != 2 and afterApplicantStatusId == 2 then
          passClassification = PassClassification.find(params[:applicant][:pass_classification_id])
          @applicant.update!(pass_classification: passClassification.classification_name)
          passClassification.pass_classification_fees.each do |pass_classification_fee|
            ApplicantFee.create!(
              applicant_id: @applicant.id,
              fee_name: pass_classification_fee.fee_name,
              amount: pass_classification_fee.amount,
              annotation: pass_classification_fee.annotation
            )
          end
        end

        # デビュー済みにする際、ユーザーを作成するflagがonであれば作成。
        if params[:create_therapist_user_flag] then
          password = SecureRandom.alphanumeric(10)
          store = Store.find(params[:applicant][:applicant_detail_attributes][:preferred_store_id])
          notification_group_id = store.store_group.line_default_target_id
          if params[:applicant][:notification_group_id].present? then
            notification_group_id = params[:applicant][:notification_group_id]
          end
          user_params = {
            user_role_id: 1,
            name: params[:applicant][:professional_name],
            login_id: params[:applicant][:applicant_login_id],
            password_digest: password,
            active_flag: 1
          }
          user_therapist_setting_params = {
            rank_id: nil,
            new_face: 1,
            therapist_back_ratio: 45,
            mikado_coin_balance: 0,
            auto_complete: params[:applicant][:applicant_auto_complete],
            mail_address: params[:applicant][:applicant_detail_attributes][:mail_address],
            account_information: nil
          }
          user_therapist_params = {
            store_id: store.id,
            therapist_id: params[:applicant][:applicant_therapist_id],
            notification_group_id: notification_group_id
          }
          flash[:create_therapist_user_params][:user_params] = user_params
          flash[:create_therapist_user_params][:user_therapist_setting_params] = user_therapist_setting_params
          flash[:create_therapist_user_params][:user_therapist_params] = user_therapist_params
          user = User.new(user_params)
          user.build_user_therapist_setting(user_therapist_setting_params)
          user.user_therapists.build(user_therapist_params)
          user.save!

          message = UsersHelper.create_login_information_message(user.name, user.login_id, password)
          send_line(notification_group_id, store.store_group, message)
        end
      end

      # ファイルの保存
      if params[:applicant][:applicant_detail_attributes][:image_one].present? then
        @applicant.save_uploaded_file("image_one", params[:applicant][:applicant_detail_attributes][:image_one])
      end
      if params[:applicant][:applicant_detail_attributes][:image_two].present? then
        @applicant.save_uploaded_file("image_two", params[:applicant][:applicant_detail_attributes][:image_two])
      end

      # 更新後、メールとLINEを送信する。
      if params[:send_mail_flag] == "1" then
        store_group = Store.find(@applicant.applicant_detail.preferred_store_id).store_group
        if params[:reply_target_id] == "" then
          # 返信先IDがなければ、新規メール
          send_mail(@applicant.applicant_detail.mail_address, store_group, params[:mail_subject], params[:mail_body])
        else
          # 返信先IDがあれば、そこに返信
          reply_thread(store_group, params[:reply_target_id], params[:mail_body])
        end
      end
      if params[:send_line_flag] == "1" then
        store_group = Store.find(@applicant.applicant_detail.preferred_store_id).store_group
        push_target_id = store_group.line_default_target_id
        if @applicant.notification_group_id.present? then
          push_target_id = @applicant.notification_group_id
        end
        send_line(push_target_id, store_group, line)
      end

      # うまく作成できたら、更新した状態を見るためにeditに戻る。
      flash[:notice] = "更新しました。"
      redirect_to("/applicants/"+params[:id]+"/edit")
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = "更新に失敗しました。"
      # 入力値はサーバー側キャッシュに保存し、フラッシュにはキーのみ保持
      cache_key = "applicant_params:" + SecureRandom.uuid
      Rails.cache.write(cache_key, applicant_params, expires_in: 10.minutes)
      flash[:applicant_params_key] = cache_key
      flash[:beforeApplicantStatusId] = beforeApplicantStatusId
      flash[:create_therapist_user_flag] = params[:create_therapist_user_flag]
      redirect_to("/applicants/"+params[:id]+"/edit")
    end
  end

  def update_pending_flag
    applicant = Applicant.find(params[:id])
    ActiveRecord::Base.transaction do
      applicant.update!(pending_flag: !applicant.pending_flag)
    end

    redirect_to("/applicants/")
  end

  def destroy
    applicant = Applicant.find(params[:id])
    applicant.applicant_detail.delete
    applicant.applicant_fees.each do |applicant_fee|
      applicant_fee.delete
    end
    applicant.delete

    redirect_to(request.referer)
  end

  private def set_applicant_select_options
    @smoking_options = ["しない", "する(接客前の禁煙可)", "する(禁煙不可)"]
    @has_tattoo_options = ["あり", "なし"]
    @therapist_experience_options = ["なし", "あり(接客なし)", "あり(接客5人以上)", "あり(接客10人以上)", "あり(接客50人以上)"]
    @mosaic_options = ["不要", "目から下薄め", "目から下濃いめ", "全モザ濃いめ", "全モザ薄め"]
  end

  private def applicant_params
    params.require(:applicant).permit(
      :applicant_store_id,
      :applicant_status_id,
      :pending_flag,
      :note,
      :pass_classification,
      :interviewer_id,
      :interview_datetime,
      :professional_name,
      :notification_group_id,
      :instructor,
      :training_datetime,
      :training_adjustment_id,
      :photographer_studio,
      :shooting_datetime,
      :shooting_adjustment_id,
      applicant_detail_attributes: [
        :id,
        :application_date,
        :preferred_store_id,
        :preferred_store_text,
        :name,
        :tel,
        :mail_address,
        :age,
        :height,
        :weight,
        :nearest_station,
        :education,
        :occupation,
        :work_frequency,
        :experience_count,
        :smoking,
        :has_tattoo,
        :therapist_experience,
        :mosaic,
        :how_to_know,
        :motivation,
        :self_pr,
        :other_questions,
        :image_one_path,
        :image_two_path
      ],
      applicant_fees_attributes: [
        :id,
        :fee_name,
        :amount,
        :annotation,
        :receive_date
      ]
    )
  end
end
