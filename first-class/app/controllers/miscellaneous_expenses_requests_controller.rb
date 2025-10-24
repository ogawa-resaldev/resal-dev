class MiscellaneousExpensesRequestsController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: :new

  def new
    @title = "雑費申請"
    @miscellaneous_expenses_request = MiscellaneousExpensesRequest.new

    @user_name = User.find(session[:user_id]).name
    @direction_select = [
      ["支払い", 1],
      ["受け取り", 2]
    ]

    if flash[:miscellaneous_expenses_request_params] != nil then
      @miscellaneous_expenses_request.assign_attributes(flash[:miscellaneous_expenses_request_params])
      @miscellaneous_expenses_request.valid?
    end
  end

  def create
    @miscellaneous_expenses_request = MiscellaneousExpensesRequest.new(miscellaneous_expenses_request_params)
    @miscellaneous_expenses_request.assign_attributes(
      user_id: session[:user_id],
      status_id: 0
    )
    begin
      ActiveRecord::Base.transaction do
        # 保存。
        @miscellaneous_expenses_request.save!
      end

      # 作成できたら、メールを送る。
      sendCreateMail(session[:user_id], miscellaneous_expenses_request_params)

      # うまく作成できたら、清算一覧に飛ぶ。
      redirect_to("/cash_flows")
    rescue ActiveRecord::RecordInvalid => e
      flash[:miscellaneous_expenses_request_params] = miscellaneous_expenses_request_params
      redirect_to("/miscellaneous_expenses_requests/new")
    end
  end

  def approve
    miscellaneous_expenses_request = MiscellaneousExpensesRequest.find(params[:id])
    cash_flow = CashFlow.new(
      occurrence_date: miscellaneous_expenses_request.occurrence_date,
      cash_flow_period: params[:cash_flow_period],
      user_id: miscellaneous_expenses_request.user_id,
      store_group_id: miscellaneous_expenses_request.store_group_id,
      miscellaneous_expenses: miscellaneous_expenses_request.miscellaneous_expenses,
      amount: miscellaneous_expenses_request.amount,
      direction: miscellaneous_expenses_request.direction
    )

    ActiveRecord::Base.transaction do
      miscellaneous_expenses_request.update!(status_id: 2)
      cash_flow.save!
    end

    # 承認されたら、メールとLINEを送る。
    sendApproveMailAndLine(cash_flow)

    redirect_to("/cash_flows")
  end

  def cancel
    miscellaneous_expenses_request = MiscellaneousExpensesRequest.find(params[:id])

    ActiveRecord::Base.transaction do
      miscellaneous_expenses_request.update!(status_id: 1)
    end

    # キャンセルされたら、メールとLINEを送る。
    sendCancelMailAndLine(miscellaneous_expenses_request)

    redirect_to("/cash_flows")
  end

  private def miscellaneous_expenses_request_params
    params.require(:miscellaneous_expenses_request).permit(
      :occurrence_date,
      :store_group_id,
      :miscellaneous_expenses,
      :amount,
      :direction
    )
  end

  private def sendCreateMail(user_id, miscellaneous_expenses_request_params)
    user = User.find(user_id)
    store_group = StoreGroup.find(miscellaneous_expenses_request_params[:store_group_id])

    subject = "雑費申請の受付"
    body = user.name + "様\r\n"
    body = body + "お世話になっております。\r\n"
    body = body + store_group.mail_name + "です。\r\n\r\n"
    body = body + "以下の雑費申請を受付ました。\r\n\r\n"
    body = body + "発生日：" + miscellaneous_expenses_request_params[:occurrence_date].gsub(/-/, '/') + "\r\n"
    body = body + "内容：" + miscellaneous_expenses_request_params[:miscellaneous_expenses] + "\r\n"
    if miscellaneous_expenses_request_params[:direction] != 1 then
      body = body + "-"
    end
    body = body + miscellaneous_expenses_request_params[:amount].to_i.to_formatted_s(:delimited) + "円\r\n\r\n"
    body = body + "事務局で申請内容を確認の上、承認することで清算計上が行えるようになります。\r\n\r\n\r\n"
    body = body + store_group.mail_name

    send_mail(user.user_therapist_setting.mail_address, store_group, subject, body)
  end

  private def sendApproveMailAndLine(cash_flow)
    user = User.find(cash_flow[:user_id])
    store_group = StoreGroup.find(cash_flow[:store_group_id])

    subject = "雑費申請の承認"
    body = user.name + "様\r\n"
    body = body + "お世話になっております。\r\n"
    body = body + store_group.mail_name + "です。\r\n\r\n"
    body = body + "以下の雑費申請を承認しました。\r\n\r\n"
    body = body + "発生日：" + cash_flow[:occurrence_date].strftime("%Y/%m/%d") + "\r\n"
    body = body + "支払い期限：" + cash_flow[:cash_flow_period].strftime("%Y/%m/%d") + "\r\n"
    body = body + "内容：" + cash_flow[:miscellaneous_expenses] + "\r\n"
    if cash_flow[:direction] != 1 then
      body = body + "-"
    end
    body = body + cash_flow[:amount].to_formatted_s(:delimited) + "円\r\n\r\n\r\n"
    body = body + store_group.mail_name

    line_target_id = store_group[:line_default_target_id]
    Store.where(store_group_id: cash_flow[:store_group_id]).each do |store|
      user_therapist = UserTherapist.find_by(user_id: cash_flow[:user_id], store_id: store[:id])
      if user_therapist.present? then
        if user_therapist["notification_group_id"] != "" then
          line_target_id = user_therapist.notification_group_id
        end
      end
    end

    send_mail(user.user_therapist_setting.mail_address, store_group, subject, body)
    send_line(line_target_id, store_group, body)
  end

  private def sendCancelMailAndLine(miscellaneous_expenses_request)
    user = User.find(miscellaneous_expenses_request[:user_id])
    store_group = StoreGroup.find(miscellaneous_expenses_request[:store_group_id])

    subject = "雑費申請の却下"
    body = user.name + "様\r\n"
    body = body + "お世話になっております。\r\n"
    body = body + store_group.mail_name + "です。\r\n\r\n"
    body = body + "以下の雑費申請を却下しました。\r\n\r\n"
    body = body + "発生日：" + miscellaneous_expenses_request[:occurrence_date].strftime("%Y/%m/%d") + "\r\n"
    body = body + "内容：" + miscellaneous_expenses_request[:miscellaneous_expenses] + "\r\n"
    if miscellaneous_expenses_request[:direction] != 1 then
      body = body + "-"
    end
    body = body + miscellaneous_expenses_request[:amount].to_formatted_s(:delimited) + "円\r\n\r\n\r\n"
    body = body + store_group.mail_name

    line_target_id = store_group[:line_default_target_id]
    Store.where(store_group_id: miscellaneous_expenses_request[:store_group_id]).each do |store|
      user_therapist = UserTherapist.find_by(user_id: miscellaneous_expenses_request[:user_id], store_id: store[:id])
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
