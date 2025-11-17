class MikadoCoinFlowsController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: [:new, :index]

  def new
    @title = "帝コイン入出庫"

    @mikado_coin_flow_collection = Form::MikadoCoinFlowCollection.new
    if flash[:mikado_coin_flow_collection_params] != nil then
      @mikado_coin_flow_collection.assign_attributes(flash[:mikado_coin_flow_collection_params])
      @mikado_coin_flow_collection.valid?
    end

    @therapist_autocomplete = []
    # 非所属セラピストに向けて帝コイン入出庫する可能性もあるので、アクティブセラピストという条件以外をつけない。
    User.where(user_role_id: 1, active_flag: 1).each do |user|
      auto_complete = user.name
      if user.user_therapist_setting.auto_complete.present? then
        auto_complete += user.user_therapist_setting.auto_complete
      end
      @therapist_autocomplete.push([user.id, user.name, auto_complete])
    end

    @directions_select = [[1,"入庫"],[2,"出庫"]]
  end

  def create
    @mikado_coin_flow_collection = Form::MikadoCoinFlowCollection.new(mikado_coin_flow_collection_params)

    begin
      ActiveRecord::Base.transaction do
        @mikado_coin_flow_collection.save!
        # 各セラピストの残高を更新し、メールを送信。
        @mikado_coin_flow_collection.target_mikado_coin_flows.each do |mikado_coin_flow|
          flow = mikado_coin_flow[:coin]
          if mikado_coin_flow[:direction] == 2 then
            # 出庫なら、マイナスにする。
            flow = flow * -1
          end
          user_therapist_setting = UserTherapistSetting.lock.find_by(user_id: mikado_coin_flow[:user_id])
          user_therapist_setting.update!(mikado_coin_balance: user_therapist_setting[:mikado_coin_balance] + flow)
          sendMail(mikado_coin_flow, user_therapist_setting[:mikado_coin_balance])
        end
      end

      # うまく作成できたら、帝コイン入出庫一覧に飛ぶ。
      redirect_to("/mikado_coin_flows")
    rescue ActiveRecord::RecordInvalid => e
      flash[:mikado_coin_flow_collection_params] = mikado_coin_flow_collection_params
      redirect_to("/mikado_coin_flows/new")
    end
  end

  def index
    @title = "帝コイン入出庫一覧"

    @error_id = ""
    @error_message = ""
    if flash[:amountErrorId] != nil then
      @error_id = flash[:amountErrorId]
      @error_message = flash[:amountErrorMessage]
    end

    # セラピスト(user_role_id = 1のユーザー)のセレクトリスト
    @therapist_select = [["指定なし",""]]
    User.all.each do |user|
      if user.user_role_id == 1 then
        @therapist_select.push([user.name, user.id])
      end
    end

    @mikado_coin_flows = MikadoCoinFlow.all
    @mikado_coin_flows = @mikado_coin_flows.where("? <= created_at", params[:mikado_coin_datetime_from] + " 0:00:00") if params[:mikado_coin_datetime_from].present?
    @mikado_coin_flows = @mikado_coin_flows.where("created_at <= ?", params[:mikado_coin_datetime_to] + " 23:59:59") if params[:mikado_coin_datetime_to].present?
    @mikado_coin_flows = @mikado_coin_flows.order(created_at: :desc)
    @mikado_coin_flows = MikadoCoinFlowRequest.where(status_id: 0) + @mikado_coin_flows
  end

  private def mikado_coin_flow_collection_params
    params.require(:form_mikado_coin_flow_collection).permit(mikado_coin_flows_attributes: [
      :register,
      :user_id,
      :coin,
      :direction,
      :direction_name,
      :reason
    ])
  end

  # 計上をメールとして送信。
  private def sendMail(mikado_coin_flow, mikado_coin_balance)
    # メール送信GASの実行。
    require 'uri'
    require 'net/http'
    require 'json'

    direction = "入庫"
    if mikado_coin_flow.direction == 2 then
      direction = "出庫"
    end

    send_mail_api = StoreGroup.find(1).mail_api
    subject = "帝コイン入出庫のお知らせ"
    body = mikado_coin_flow.user.name + "様\r\n\r\n"
    body = body + "お世話になっております。\r\n"
    body = body + "帝事務局です。\r\n\r\n"
    body = body + "帝コインの入出庫を行いました。\r\n\r\n"
    body = body + "内容：" + mikado_coin_flow.coin.to_s + "コインの" + direction + "\r\n"
    body = body + "理由：" + mikado_coin_flow.reason + "\r\n"
    body = body + "入出庫後の残高：" + mikado_coin_balance.to_s + "コイン\r\n\r\n"
    body = body + "以上、ご確認をお願いいたします。\r\n\r\n"
    body = body + "帝事務局"

    payload = {
      # なんちゃってtoken
      token: ENV["SEND_MAIL_PESUDO_TOKEN"],
      action: "createNew",
      recipientEmailAddress: mikado_coin_flow.user.user_therapist_setting[:mail_address],
      subject: "帝コイン入出庫のお知らせ",
      body: body,
      options: {
        name: "帝事務局"
      }
    }
    headers = {
      "Content-Type":"application/json"
    }
    uri = URI.parse(send_mail_api)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"
    begin
      response = http.post(uri.path, payload.to_json, headers)
    rescue ActiveRecord::RecordInvalid => e
      # エラー発生したら、インターナルエラー返す。
      return error!({error: "メールの送信に失敗しました。error:" + e.message, backtrace: e.backtrace[0]}, 500)
    end
  end
end
