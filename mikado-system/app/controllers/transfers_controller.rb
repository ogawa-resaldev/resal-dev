class TransfersController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in

  def create
    transfer_deadline = Time.current.change(hour: 23, min: 59, sec: 59)
    if params[:direction] == "2" then
      transfer_deadline = transfer_deadline.since(2.weeks)
    end
    @transfer = Transfer.new(
      user_id: params[:user_id],
      store_group_id: params[:store_group_id],
      direction: params[:direction],
      transfer_deadline: transfer_deadline
    )

    begin
      ActiveRecord::Base.transaction do
        # すでに振込IDが存在する清算がある場合、連打が予想されるので振込作成しない。
        isCreatedFlag = false
        params[:cash_flow_ids].split(",").each do |cash_flow_id|
          target_cash_flow = CashFlow.lock.find(cash_flow_id)
          if target_cash_flow.transfer_id.present? then
            isCreatedFlag = true
          end
        end
        if !isCreatedFlag then
          @transfer.save!
          transfer_id = @transfer.id
          # 清算の振込IDをupdate。
          params[:cash_flow_ids].split(",").each do |cash_flow_id|
            target_cash_flow = CashFlow.lock.find(cash_flow_id)
            target_cash_flow.update!(transfer_id: transfer_id)
          end
          # うまく作成できたら、通知を送って一覧に飛ぶ。(フラグ制御)
          if params[:send_notifications_flag] then
            sendCreateTransferMailAndLine(@transfer)
          end
        end
        redirect_to("/transfers")
      end
    rescue ActiveRecord::RecordInvalid => e
      # エラーあったら、清算の一覧に飛ぶ。
      redirect_to "/cash_flows"
    end
  end

  def index
    @title = "振込一覧"

    @store_group_list = {}
    store_groups = StoreGroup.all_by_user(session[:user_id])
    store_groups.each do |store_group|
      @store_group_list[store_group.id] = store_group.name
    end

    @transfers = Transfer.all_by_user(session[:user_id])
    @therapist_autocomplete = []
    # 非所属セラピストに向けて雑費作成する可能性もあるので、アクティブセラピストという条件以外をつけない。
    User.where(user_role_id: 1, active_flag: 1).each do |user|
      auto_complete = user.name
      if user.user_therapist_setting.auto_complete.present? then
        auto_complete += user.user_therapist_setting.auto_complete
      end
      @therapist_autocomplete.push([user.id, user.name, auto_complete])
    end
    if params[:therapist_id].present? then
      @transfers = @transfers.where(user_id: params[:therapist_id])
    end

    @transfers = @transfers.where.not(confirmation_flag: true) if !params[:historical].present?
    @transfers = @transfers.order("confirmation_flag ASC", "transfer_date ASC")
  end

  def reject
    transfer = Transfer.find(params[:id])

    # 清算の解除。
    CashFlow.where(transfer_id: params[:id]).each do |cashFlow|
      cashFlow.update!(transfer_id: nil)
    end

    # 振込の削除。
    transfer.delete

    sendRejectTransferMailAndLine(transfer)
    redirect_to(request.referer)
  end

  def update_cash_flow
    transfer = Transfer.find(params[:transfer][:transfer_id])

    # 清算の解除。
    CashFlow.where(id: params[:transfer][:remove_cash_flow_ids].split(",")).each do |cashFlow|
      cashFlow.update!(transfer_id: nil)
    end

    # 清算を計算して、振込IDを挿入。
    CashFlow.where(id: params[:transfer][:add_cash_flow_ids].split(",")).each do |cashFlow|
      cashFlow.update!(transfer_id: transfer[:id])
    end

    transfer.update!(
      direction: transfer.sum_cash_flows[:direction]
    )

    # うまく作成できたら、通知を送って一覧に飛ぶ。(フラグ制御)
    if params[:send_notifications_flag] then
      sendChangeTransferMailAndLine(transfer)
    end
    redirect_to(request.referer)
  end

  def set_transfer
    transfer = Transfer.find(params[:id])
    transfer.update!({transfer_date: params[:transfer_date],transfer_amount: params[:transfer_amount]})

    # 設定したら、通知を送って元のurlに戻る。(フラグ制御)
    if params[:send_notifications_flag] then
      sendSetTransferMailAndLine(transfer)
    end
    redirect_to(request.referer)
  end

  def confirm
    transfer = Transfer.find(params[:id])
    transfer.update!(confirmation_flag: 1)

    # 確認したら、通知を送って元のurlに戻る。(フラグ制御)
    if params[:send_notifications_flag] then
      sendConfirmTransferMailAndLine(transfer)
    end
    redirect_to(request.referer)
  end

  private def sendCreateTransferMailAndLine(transfer)
    store_group = transfer.store_group

    subject = "振込内容の確認"

    body = transfer.user.name + "様"
    body = body + "\r\n"
    body = body + "お世話になっております。\r\n"
    body = body + store_group.mail_name + "です。\r\n\r\n"
    if transfer.direction == 1 then
      body = body + "以下内容の振込を作成しました。\r\n\r\n"
    else
      body = body + "以下内容の振込依頼を作成しました。\r\n\r\n"
    end
    CashFlow.where(transfer_id: transfer.id).order(occurrence_date: :asc).each do |cash_flow|
      body = body + cash_flow[:occurrence_date].strftime("%m/%d") + " "
      if cash_flow[:direction] != 1 then
        # セラピスト→店の方向でなければ、「-」を付ける。
        body = body + "-"
      end
      body = body + cash_flow[:amount].to_formatted_s(:delimited) + "円 "
      if cash_flow[:reservation_id] != nil then
        body = body + "予約 (" + Reservation.find(cash_flow.reservation_id)[:name] + "様)\r\n"
      elsif cash_flow[:bar_sales_id] != nil then
        body = body + "バー報酬\r\n"
      else
        body = body + cash_flow.miscellaneous_expenses + "\r\n"
      end
    end
    body = body + "\r\n合計 "
    if transfer.direction != 1 then
      body = body + "-"
    end
    body = body + transfer.sum_cash_flows[:amount].to_formatted_s(:delimited) + "円\r\n\r\n"
    if transfer.direction == 1 then
      body = body + transfer.sum_cash_flows[:amount].to_formatted_s(:delimited) + "円を、以下の口座にお振り込みください。\r\n"
      body = body + "==========\r\n"
      body = body + store_group.mail_transfer_bank
      body = body + "\r\n\r\n==========\r\n"
      body = body + "また、振込が完了した際には振込一覧にて振込日の設定を行ってください。\r\n\r\n"
    else
      body = body + transfer.sum_cash_flows[:amount].to_formatted_s(:delimited) + "円を、事務局での確認が取れ次第以下の口座にお振り込みいたします。\r\n"
      body = body + "==========\r\n" + transfer.user.user_therapist_setting.account_information + "\r\n==========\r\n\r\n"
    end
    body = body + "以上、ご確認をお願いいたします。\r\n\r\n"
    body = body + store_group.mail_name

    line_target_id = store_group[:line_default_target_id]
    Store.where(store_group_id: store_group[:id]).each do |store|
      user_therapist = UserTherapist.find_by(user_id: transfer.user.id, store_id: store[:id])
      if user_therapist.present? then
        if user_therapist["notification_group_id"] != "" then
          line_target_id = user_therapist.notification_group_id
        end
      end
    end

    send_mail(transfer.user.user_therapist_setting.mail_address, store_group, subject, body)
    send_line(line_target_id, store_group, body)
  end

  private def sendChangeTransferMailAndLine(transfer)
    store_group = transfer.store_group

    subject = "振込内容の変更"

    body = transfer.user.name + "様"
    body = body + "\r\n"
    body = body + "お世話になっております。\r\n"
    body = body + store_group.mail_name + "です。\r\n\r\n"
    if transfer.direction == 1 then
      body = body + "振込が以下内容に変更されました。\r\n\r\n"
    else
      body = body + "振込依頼が以下内容に変更されました。\r\n\r\n"
    end
    CashFlow.where(transfer_id: transfer.id).order(occurrence_date: :asc).each do |cash_flow|
      body = body + cash_flow[:occurrence_date].strftime("%m/%d") + " "
      if cash_flow[:direction] != transfer.direction then
        body = body + "-"
      end
      body = body + cash_flow[:amount].to_formatted_s(:delimited) + "円 "
      if cash_flow[:reservation_id] != nil then
        body = body + "予約 (" + Reservation.find(cash_flow.reservation_id)[:name] + "様)\r\n"
      elsif cash_flow[:bar_sales_id] != nil then
        body = body + "バー報酬\r\n"
      else
        body = body + cash_flow.miscellaneous_expenses + "\r\n"
      end
    end
    body = body + "\r\n合計 " + transfer.sum_cash_flows[:amount].to_formatted_s(:delimited) + "円\r\n\r\n"
    if transfer.direction == 1 then
      body = body + "上記金額を、以下の口座にお振り込みください。\r\n"
      body = body + "==========\r\n"
      body = body + store_group.mail_transfer_bank + "\r\n"
      body = body + "\r\n==========\r\n"
      body = body + "また、振込が完了した際には振込一覧にて振込日の設定を行ってください。\r\n\r\n"
    else
      body = body + "上記金額を、事務局での確認が取れ次第以下の口座にお振り込みいたします。\r\n"
      body = body + "==========\r\n" + transfer.user.user_therapist_setting.account_information + "\r\n==========\r\n\r\n"
    end
    body = body + "以上、ご確認をお願いいたします。\r\n\r\n"
    body = body + store_group.mail_name

    line_target_id = store_group[:line_default_target_id]
    Store.where(store_group_id: store_group[:id]).each do |store|
      user_therapist = UserTherapist.find_by(user_id: transfer.user.id, store_id: store[:id])
      if user_therapist.present? then
        if user_therapist["notification_group_id"] != "" then
          line_target_id = user_therapist.notification_group_id
        end
      end
    end

    send_mail(transfer.user.user_therapist_setting.mail_address, store_group, subject, body)
    send_line(line_target_id, store_group, body)
  end

  private def sendSetTransferMailAndLine(transfer)
    store_group = transfer.store_group

    subject = "振込の受付"
    if transfer.direction == 2 then
      subject = "振込の確認依頼"
    end

    body = transfer.user.name + "様"
    body = body + "\r\n"
    body = body + "お世話になっております。\r\n"
    body = body + store_group.mail_name + "です。\r\n\r\n"
    if transfer.direction == 1 then
      body = body + "以下内容の振込を受付けました。\r\n\r\n"
    else
      body = body + "以下内容の振込を行いました。\r\n\r\n"
    end
    CashFlow.where(transfer_id: transfer.id).order(occurrence_date: :asc).each do |cash_flow|
      body = body + cash_flow[:occurrence_date].strftime("%m/%d") + " "
      if cash_flow[:direction] != 1 then
        # セラピスト→店の方向でなければ、「-」を付ける。
        body = body + "-"
      end
      body = body + cash_flow[:amount].to_formatted_s(:delimited) + "円 "
      if cash_flow[:reservation_id] != nil then
        body = body + "予約 (" + Reservation.find(cash_flow.reservation_id)[:name] + "様)\r\n"
      elsif cash_flow[:bar_sales_id] != nil then
        body = body + "バー報酬\r\n"
      else
        body = body + cash_flow.miscellaneous_expenses + "\r\n"
      end
    end
    body = body + "\r\n合計 "
    if transfer.direction != 1 then
      body = body + "-"
    end
    body = body + transfer.sum_cash_flows[:amount].to_formatted_s(:delimited) + "円\r\n\r\n"
    if transfer.direction == 1 then
      body = body + "事務局で振込が確認できた際に、確認メールを送信いたします。\r\n\r\n"
      body = body + "以上、ご確認をお願いいたします。\r\n\r\n"
    else
      body = body + "上記振込のご確認をお願いいたします。\r\n\r\n"
    end
    body = body + store_group.mail_name

    line_target_id = store_group[:line_default_target_id]
    Store.where(store_group_id: store_group[:id]).each do |store|
      user_therapist = UserTherapist.find_by(user_id: transfer.user.id, store_id: store[:id])
      if user_therapist.present? then
        if user_therapist["notification_group_id"] != "" then
          line_target_id = user_therapist.notification_group_id
        end
      end
    end

    send_mail(transfer.user.user_therapist_setting.mail_address, store_group, subject, body)
    send_line(line_target_id, store_group, body)
  end

  private def sendRejectTransferMailAndLine(transfer)
    store_group = transfer.store_group

    subject = "振込を却下しました"

    body = transfer.user.name + "様"
    body = body + "\r\n"
    body = body + "お世話になっております。\r\n"
    body = body + store_group.mail_name + "です。\r\n\r\n"
    body = body + "精算条件を満たさない精算分が含まれているため振込みを却下させていただきました。\r\n\r\n"
    body = body + "店舗からの振込み分は他の報酬分との清算をお願いします。\r\n"
    body = body + "予約日（発生日）から10〜14日たっても清算できない場合、振込みの申請が可能です。\r\n"
    body = body + "精算のルールについて、詳しくは下記をご確認ください。\r\n"
    body = body + "https://docs.google.com/document/d/1yNPcc1MqD9X53JE4F_9BpB7drhcxvgywSlwjCOcYYQ8/edit\r\n\r\n"
    body = body + "以上、ご確認をお願いいたします。"

    line_target_id = store_group[:line_default_target_id]
    Store.where(store_group_id: store_group[:id]).each do |store|
      user_therapist = UserTherapist.find_by(user_id: transfer.user.id, store_id: store[:id])
      if user_therapist.present? then
        if user_therapist["notification_group_id"] != "" then
          line_target_id = user_therapist.notification_group_id
        end
      end
    end

    send_mail(transfer.user.user_therapist_setting.mail_address, store_group, subject, body)
    send_line(line_target_id, store_group, body)
  end

  private def sendConfirmTransferMailAndLine(transfer)
    store_group = transfer.store_group

    subject = "振込の確認"

    body = transfer.user.name + "様"
    body = body + "\r\n"
    body = body + "お世話になっております。\r\n"
    body = body + store_group.mail_name + "です。\r\n\r\n"
    if transfer.direction == 1 then
      body = body + "以下内容の振込について、事務局側で確認ができました。\r\n\r\n"
    else
      body = body + "以下内容の振込について、ご確認いただきありがとうございます。\r\n\r\n"
    end
    CashFlow.where(transfer_id: transfer.id).order(occurrence_date: :asc).each do |cash_flow|
      body = body + cash_flow[:occurrence_date].strftime("%m/%d") + " "
      if cash_flow[:direction] != 1 then
        # セラピスト→店の方向でなければ、「-」を付ける。
        body = body + "-"
      end
      body = body + cash_flow[:amount].to_formatted_s(:delimited) + "円 "
      if cash_flow[:reservation_id] != nil then
        body = body + "予約 (" + Reservation.find(cash_flow.reservation_id)[:name] + "様)\r\n"
      elsif cash_flow[:bar_sales_id] != nil then
        body = body + "バー報酬\r\n"
      else
        body = body + cash_flow.miscellaneous_expenses + "\r\n"
      end
    end
    body = body + "\r\n合計 "
    if transfer.direction != 1 then
      body = body + "-"
    end
    body = body + transfer.sum_cash_flows[:amount].to_formatted_s(:delimited) + "円\r\n\r\n"
    body = body + "今後とも、よろしくお願いいたします。\r\n\r\n"
    body = body + store_group.mail_name

    line_target_id = store_group[:line_default_target_id]
    Store.where(store_group_id: store_group[:id]).each do |store|
      user_therapist = UserTherapist.find_by(user_id: transfer.user.id, store_id: store[:id])
      if user_therapist.present? then
        if user_therapist["notification_group_id"] != "" then
          line_target_id = user_therapist.notification_group_id
        end
      end
    end

    send_mail(transfer.user.user_therapist_setting.mail_address, store_group, subject, body)
    send_line(line_target_id, store_group, body)
  end
end
