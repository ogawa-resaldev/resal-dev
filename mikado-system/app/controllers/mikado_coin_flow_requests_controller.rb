class MikadoCoinFlowRequestsController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: :new

  def new
    @title = "帝コイン入出庫申請"
    @mikado_coin_flow_request = MikadoCoinFlowRequest.new
    @mikado_coin_flow_request.assign_attributes(
      user_id: session[:user_id]
    )

    user = User.find(session[:user_id])
    @user_name = user.name
    @mikado_coin_balance = user.user_therapist_setting.mikado_coin_balance
    @directions_select = [["受け取り",1],["利用",2]]

    if flash[:mikado_coin_flow_request_params] != nil then
      @mikado_coin_flow_request.assign_attributes(flash[:mikado_coin_flow_request_params])
      @mikado_coin_flow_request.valid?
    end
  end

  def create
    @mikado_coin_flow_request = MikadoCoinFlowRequest.new(mikado_coin_flow_request_params)
    @mikado_coin_flow_request.assign_attributes(
      user_id: session[:user_id],
      status_id: 0
    )
    begin
      ActiveRecord::Base.transaction do
        # 保存。
        @mikado_coin_flow_request.save!
      end

      # 作成できたら、メールを送る。
      sendCreateMail(session[:user_id], mikado_coin_flow_request_params)

      # うまく作成できたら、ユーザー表示に飛ぶ。
      redirect_to("/users/" + session[:user_id].to_s + "/edit")
    rescue ActiveRecord::RecordInvalid => e
      flash[:mikado_coin_flow_request_params] = mikado_coin_flow_request_params
      redirect_to("/mikado_coin_flow_requests/new")
    end
  end

  def approve
    mikado_coin_flow_request = MikadoCoinFlowRequest.find(params[:id])

    ActiveRecord::Base.transaction do
      begin
        mikado_coin_flow = MikadoCoinFlow.new(
          user_id: mikado_coin_flow_request.user_id,
          reason: mikado_coin_flow_request.reason,
          direction: mikado_coin_flow_request.direction,
          coin: mikado_coin_flow_request.coin
        )
        flow = mikado_coin_flow[:coin]
        if mikado_coin_flow[:direction] == 2 then
          # 出庫なら、マイナスにする。
          flow = flow * -1
        end
        mikado_coin_flow.save!
        mikado_coin_flow_request.update!(status_id: 2)
        user_therapist_setting = UserTherapistSetting.lock.find_by(user_id: mikado_coin_flow[:user_id])
        user_therapist_setting.update!(mikado_coin_balance: user_therapist_setting[:mikado_coin_balance] + flow)

        # メールとLINEを送る。
        sendApproveMailAndLine(mikado_coin_flow)
      rescue ActiveRecord::RecordInvalid => e
        flash[:amountErrorId] = mikado_coin_flow_request.id
        flash[:amountErrorMessage] = e.record.errors["base"][0]
      end

      # 元のurlに戻る。
      redirect_to(request.referer)
    end
  end

  def cancel
    mikado_coin_flow_request = MikadoCoinFlowRequest.find(params[:id])

    ActiveRecord::Base.transaction do
      mikado_coin_flow_request.update!(status_id: 1)
    end

    # キャンセルされたら、メールとLINEを送る。
    sendCancelMailAndLine(mikado_coin_flow_request)

    # 元のurlに戻る。
    redirect_to(request.referer)
  end

  private def mikado_coin_flow_request_params
    params.require(:mikado_coin_flow_request).permit(
      :user_id,
      :reason,
      :direction,
      :coin
    )
  end

  private def sendCreateMail(user_id, mikado_coin_flow_request_params)
    user = User.find(user_id)
    store_group = StoreGroup.find(1)

    subject = "帝コイン入出庫申請の受付"
    body = user.name + "様\r\n"
    body = body + "お世話になっております。\r\n"
    body = body + store_group.mail_name + "です。\r\n\r\n"
    body = body + "以下内容の入出庫申請を受付ました。\r\n\r\n"
    body = body + mikado_coin_flow_request_params[:reason] + "\r\n"
    if mikado_coin_flow_request_params[:direction] != 1 then
      body = body + "-"
    end
    body = body + mikado_coin_flow_request_params[:coin].to_i.to_formatted_s(:delimited) + "コイン\r\n\r\n"
    body = body + "事務局で申請内容を確認の上、計上することで帝コインが入出庫されます。\r\n\r\n\r\n"
    body = body + store_group.mail_name

    send_mail(user.user_therapist_setting.mail_address, store_group, subject, body)
  end

  private def sendApproveMailAndLine(mikado_coin_flow)
    user = User.find(mikado_coin_flow[:user_id])
    store_group = StoreGroup.find(1)

    subject = "帝コイン入出庫申請の承認"
    body = user.name + "様\r\n"
    body = body + "お世話になっております。\r\n"
    body = body + store_group.mail_name + "です。\r\n\r\n"
    body = body + "以下内容の雑費申請を承認しました。\r\n\r\n"
    body = body + mikado_coin_flow[:reason] + "\r\n"
    if mikado_coin_flow[:direction] != 1 then
      body = body + "-"
    end
    body = body + mikado_coin_flow[:coin].to_formatted_s(:delimited) + "コイン\r\n\r\n\r\n"
    body = body + store_group.mail_name

    line_target_id = store_group[:line_default_target_id]
    Store.where(store_group_id: store_group[:id]).each do |store|
      user_therapist = UserTherapist.find_by(user_id: mikado_coin_flow[:user_id], store_id: store[:id])
      if user_therapist.present? then
        if user_therapist["notification_group_id"] != "" then
          line_target_id = user_therapist.notification_group_id
        end
      end
    end

    send_mail(user.user_therapist_setting.mail_address, store_group, subject, body)
    send_line(line_target_id, store_group, body)
  end

  private def sendCancelMailAndLine(mikado_coin_flow_request)
    user = User.find(mikado_coin_flow_request[:user_id])
    store_group = StoreGroup.find(1)

    subject = "帝コイン入出庫申請の却下"
    body = user.name + "様\r\n"
    body = body + "お世話になっております。\r\n"
    body = body + store_group.mail_name + "です。\r\n\r\n"
    body = body + "以下内容の帝コイン入出庫申請を却下しました。\r\n\r\n"
    body = body + mikado_coin_flow_request[:reason] + "\r\n"
    if mikado_coin_flow_request[:direction] != 1 then
      body = body + "-"
    end
    body = body + mikado_coin_flow_request[:coin].to_formatted_s(:delimited) + "コイン\r\n\r\n\r\n"
    body = body + store_group.mail_name

    line_target_id = store_group[:line_default_target_id]
    Store.where(store_group_id: store_group[:id]).each do |store|
      user_therapist = UserTherapist.find_by(user_id: mikado_coin_flow_request[:user_id], store_id: store[:id])
      if user_therapist.present? then
        if user_therapist["notification_group_id"] != "" then
          line_target_id = user_therapist.notification_group_id
        end
      end
    end

    send_mail(user.user_therapist_setting.mail_address, store_group, subject, body)
    send_line(line_target_id, store_group, body)
  end
end
