class CashFlowsController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: :new

  def new
    @title = "清算新規作成(雑費)"

    @cash_flow = CashFlow.new
    if flash[:cash_flow_params] != nil then
      @cash_flow.assign_attributes(flash[:cash_flow_params])
      @cash_flow.valid?
    end

    @therapist_autocomplete = []
    # 非所属セラピストに向けて雑費作成する可能性もあるので、アクティブセラピストという条件以外をつけない。
    User.where(user_role_id: 1, active_flag: 1).each do |user|
      auto_complete = user.name
      if user.user_therapist_setting.auto_complete.present? then
        auto_complete += user.user_therapist_setting.auto_complete
      end
      @therapist_autocomplete.push([user.id, user.name, auto_complete])
    end

    @direction_select = [
      ["キャスト→店", 1],
      ["店→キャスト", 2]
    ]
  end

  def create
    cash_flow = CashFlow.new(cash_flow_params)
    begin
      ActiveRecord::Base.transaction do
        cash_flow.save!
      end

      # 作成したら、メールを送信。
      # sendCreateMail(cash_flow)

      # うまく作成できたら、清算一覧に飛ぶ。
      flash[:notice] = "作成しました。"
      redirect_to("/cash_flows")
    rescue ActiveRecord::RecordInvalid => e
      flash[:cash_flow_params] = cash_flow_params
      redirect_to("/cash_flows/new")
    end
  end

  def index
    @title = "清算一覧"

    @store_group_list = {}
    store_groups = StoreGroup.all_by_user(session[:user_id])
    store_groups.each do |store_group|
      @store_group_list[store_group.id] = store_group.name
    end

    cash_flows = CashFlow.all_by_user(session[:user_id]).where(transfer_id: nil)
    # 雑費申請
    miscellaneous_expenses_requests = MiscellaneousExpensesRequest.all_by_user(session[:user_id]).order("user_id DESC", "occurrence_date ASC").where(status_id: 0)

    @therapist_autocomplete = []
    # 非所属セラピストに向けて雑費作成する可能性もあるので、アクティブセラピストという条件以外をつけない。
    User.where(user_role_id: 1, active_flag: 1).each do |user|
      auto_complete = user.name
      if user.user_therapist_setting.auto_complete.present? then
        auto_complete += user.user_therapist_setting.auto_complete
      end
      @therapist_autocomplete.push([user.id, user.name, auto_complete])
    end

    if params[:therapist_id].present?
      cash_flows = cash_flows.merge(CashFlow.where(user_id: params[:therapist_id]))
      miscellaneous_expenses_requests = miscellaneous_expenses_requests.merge(MiscellaneousExpensesRequest.where(user_id: params[:therapist_id]))
    end
    cash_flows = cash_flows.order("user_id DESC", "occurrence_date ASC")

    @cash_flows = miscellaneous_expenses_requests + cash_flows
  end

  def destroy
    cash_flow = CashFlow.find(params[:id])
    cash_flow.delete

    # 削除したら、メールを送信。
    # sendDeleteMail(cash_flow)

    # うまく削除できたら、元のurlに戻る。
    flash[:notice] = "削除しました。"
    redirect_to(request.referer)
  end

  private def cash_flow_params
    params.require(:cash_flow).permit(
      :occurrence_date,
      :cash_flow_period,
      :user_id,
      :store_group_id,
      :miscellaneous_expenses,
      :amount,
      :direction
    )
  end

  private def sendCreateMail(cash_flow)
    user = User.find(cash_flow[:user_id])
    store_group = StoreGroup.find(cash_flow[:store_group_id])

    subject = "雑費の作成"
    body = user.name + "様\r\n"
    body = body + "お世話になっております。\r\n"
    body = body + store_group.mail_name + "です。\r\n\r\n"
    body = body + "以下の雑費を作成しました。\r\n\r\n"
    body = body + "発生日：" + cash_flow[:occurrence_date].strftime("%Y/%m/%d") + "\r\n"
    body = body + "内容：" + cash_flow[:miscellaneous_expenses] + "\r\n"
    if cash_flow[:direction] != 1 then
      body = body + "-"
    end
    body = body + cash_flow[:amount].to_formatted_s(:delimited) + "円\r\n\r\n\r\n"
    body = body + store_group.mail_name

    send_mail(user.user_therapist_setting.mail_address, store_group, subject, body)
  end

  private def sendDeleteMail(cash_flow)
    user = User.find(cash_flow[:user_id])
    store_group = StoreGroup.find(cash_flow[:store_group_id])

    subject = "雑費の削除"
    body = user.name + "様\r\n"
    body = body + "お世話になっております。\r\n"
    body = body + store_group.mail_name + "です。\r\n\r\n"
    body = body + "以下の雑費を削除しました。\r\n\r\n"
    body = body + "発生日：" + cash_flow[:occurrence_date].strftime("%Y/%m/%d") + "\r\n"
    body = body + "内容：" + cash_flow[:miscellaneous_expenses] + "\r\n"
    if cash_flow[:direction] != 1 then
      body = body + "-"
    end
    body = body + cash_flow[:amount].to_formatted_s(:delimited) + "円\r\n\r\n\r\n"
    body = body + store_group.mail_name

    send_mail(user.user_therapist_setting.mail_address, store_group, subject, body)
  end
end
