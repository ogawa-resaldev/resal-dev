class SalesController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: :index

  def index
    @title = "売上一覧"

    @grouping_select = [
      ["店舗グループ", "store_group"],
      ["店舗", "store"],
      ["セラピスト", "therapist"],
      ["店舗×セラピスト", "store_therapist"]
    ]

    # グルーピングを設定。
    grouping = "store_group"
    grouping = params[:grouping] if params[:grouping].present?

    # 期間の範囲を設定。(初期値は、今月1日〜今月末日)
    start_of_month = Time.current.beginning_of_month
    sale_datetime_from = start_of_month.prev_month.strftime("%Y-%m-%d")
    sale_datetime_from = params[:sale_datetime_from] if params[:sale_datetime_from].present?
    sale_datetime_to = start_of_month.yesterday.strftime("%Y-%m-%d")
    sale_datetime_to = params[:sale_datetime_to] if params[:sale_datetime_to].present?
    reservations = Reservation.all_by_user(session[:user_id]).where(reservation_status_id: 4).where("? <= reservation_datetime", start_of_month.prev_month.strftime("%Y-%m-%d") + " 0:00:00").where("reservation_datetime <= ?", start_of_month.yesterday.strftime("%Y-%m-%d") + " 23:59:59")

    sales = getSales(grouping, sale_datetime_from, sale_datetime_to)

    # 表示するレコード。
    @sales = sales[:sales]
    # 表示する項目。[項目名,表示する項目のタイプ(string,amount)]のリスト。
    @sale_columns = sales[:sale_columns]
  end

  def getSales(grouping, sale_datetime_from, sale_datetime_to)
    sale_columns = []
    sales = []
    case grouping
    when "store_group"
      sale_columns = [["店舗グループ","string"], ["総売上","amount"], ["キャストからの受け取り費用","amount"], ["予約売上","amount"], ["予約店舗分売上","amount"]]
      # {店舗グループID:[店舗グループ名,総売上,キャストからの受け取り費用,予約売上,予約店舗分売上]}のリストを作成。
      sale_list = {}
      StoreGroup.all_by_user(session[:user_id]).each do |store_group|
        sale_list[store_group.id] = [store_group.name, 0, 0, 0, 0]
      end
      # 求人売上
      applicants = Applicant.all_by_user(session[:user_id])
        .joins(:applicant_fees)
        .where("? <= applicant_fees.receive_date", sale_datetime_from)
        .where("applicant_fees.receive_date <= ?", sale_datetime_to)
        .distinct
      applicants.each do |applicant|
        applicant.applicant_fees.each do |applicant_fee|
          sale_list[applicant.applicant_detail.preferred_store.store_group.id][1] += applicant_fee.amount
          sale_list[applicant.applicant_detail.preferred_store.store_group.id][2] += applicant_fee.amount
        end
      end
      # 予約売上
      reservations = Reservation.all_by_user(session[:user_id]).where(reservation_status_id: 4).where("? <= reservation_datetime", sale_datetime_from + " 0:00:00").where("reservation_datetime <= ?", sale_datetime_to + " 23:59:59")
      reservations.each do |reservation|
        sum_amount = reservation.reservation_courses.sum_amount + reservation.reservation_fees.sum_amount
        sum_back_therapist_amount = reservation.reservation_courses.sum_back_therapist_amount + reservation.reservation_fees.sum_back_therapist_amount
        sale_list[reservation.store.store_group.id][1] += sum_amount
        sale_list[reservation.store.store_group.id][3] += sum_amount
        sale_list[reservation.store.store_group.id][4] += sum_amount - sum_back_therapist_amount
      end
      sale_list.values.each do |sale|
        rate = 0
        if sale[3] != 0 then
          rate = sprintf("%.1f", sale[4] * 100.0 / sale[3])
        end
        sale[4] = number_format(sale[4]) + " (" + rate.to_s + "%)"
      end
      sales = sale_list.values
    when "store"
      sale_columns = [["店舗","string"], ["総売上","amount"], ["キャストからの受け取り費用","amount"], ["予約売上","amount"], ["予約店舗分売上","amount"]]
      # {店舗ID:[店舗名,総売上,キャストからの受け取り費用,予約売上,予約店舗分売上]}のリストを作成。
      sale_list = {}
      Store.all_by_user(session[:user_id]).each do |store|
        sale_list[store.id] = [store.store_name, 0, 0, 0, 0]
      end
      # 求人売上
      applicants = Applicant.all_by_user(session[:user_id])
        .joins(:applicant_fees)
        .where("? <= applicant_fees.receive_date", sale_datetime_from)
        .where("applicant_fees.receive_date <= ?", sale_datetime_to)
        .distinct
      applicants.each do |applicant|
        applicant.applicant_fees.each do |applicant_fee|
          sale_list[applicant.applicant_detail.preferred_store_id][1] += applicant_fee.amount
          sale_list[applicant.applicant_detail.preferred_store_id][2] += applicant_fee.amount
        end
      end
      # 予約売上
      reservations = Reservation.all_by_user(session[:user_id]).where(reservation_status_id: 4).where("? <= reservation_datetime", sale_datetime_from + " 0:00:00").where("reservation_datetime <= ?", sale_datetime_to + " 23:59:59")
      reservations.each do |reservation|
        sum_amount = reservation.reservation_courses.sum_amount + reservation.reservation_fees.sum_amount
        sum_back_therapist_amount = reservation.reservation_courses.sum_back_therapist_amount + reservation.reservation_fees.sum_back_therapist_amount
        sale_list[reservation.store.id][1] += sum_amount
        sale_list[reservation.store.id][3] += sum_amount
        sale_list[reservation.store.id][4] += sum_amount - sum_back_therapist_amount
      end
      sale_list.values.each do |sale|
        rate = 0
        if sale[3] != 0 then
          rate = sprintf("%.1f", sale[4] * 100.0 / sale[3])
        end
        sale[4] = number_format(sale[4]) + " (" + rate.to_s + "%)"
      end
      sales = sale_list.values
    when "therapist"
      sale_columns = [["セラピスト", "string"], ["予約数", "string"], ["リピート", "string"], ["売上", "amount"], ["店舗分売上", "amount"]]
      # {ユーザーID:[ユーザー名,予約数,リピート,売上,店舗分売上]}のリストを作成。
      reservation_sales = {0=>["該当セラピストなし",0,0,0,0]}
      User.all_by_user(session[:user_id]).where(active_flag: 1, user_role_id: 1).each do |user|
        reservation_sales[user.id] = [user.name, 0, 0, 0, 0]
      end
      reservations = Reservation.all_by_user(session[:user_id]).where(reservation_status_id: 4).where("? <= reservation_datetime", sale_datetime_from + " 0:00:00").where("reservation_datetime <= ?", sale_datetime_to + " 23:59:59")
      reservations.each do |reservation|
        user_therapist = UserTherapist.find_by(store_id: reservation.store_id, therapist_id: reservation.therapist_id)
        sum_amount = reservation.reservation_courses.sum_amount + reservation.reservation_fees.sum_amount
        sum_back_therapist_amount = reservation.reservation_courses.sum_back_therapist_amount + reservation.reservation_fees.sum_back_therapist_amount
        if user_therapist.present? then
          reservation_sales[user_therapist.user_id][1] += 1
          if reservation.reservation_type_id == 1 then
            reservation_sales[user_therapist.user_id][2] += 1
          end
          reservation_sales[user_therapist.user_id][3] += sum_amount
          reservation_sales[user_therapist.user_id][4] += sum_amount - sum_back_therapist_amount
        else
          reservation_sales[0][1] += 1
          if reservation.reservation_type_id == 1 then
            reservation_sales[0][2] += 1
          end
          reservation_sales[0][3] += sum_amount
          reservation_sales[0][4] += sum_amount - sum_back_therapist_amount
        end
      end
      reservation_sales.values.each do |reservation_sale|
        # 予約の入っているユーザーだけをリストにする。
        if reservation_sale[1] != 0 then
          repeat_rate = 0
          sale_rate = 0
          repeat_rate = sprintf("%.1f", reservation_sale[2] * 100.0 / reservation_sale[1])
          if reservation_sale[3] != 0 then
            sale_rate = sprintf("%.1f", reservation_sale[4] * 100.0 / reservation_sale[3])
          end
          sales.push([
            reservation_sale[0],
            reservation_sale[1],
            number_format(reservation_sale[2]) + " (" + repeat_rate.to_s + "%)",
            reservation_sale[3],
            number_format(reservation_sale[4]) + " (" + sale_rate.to_s + "%)"
          ])
        end
      end
    when "store_therapist"
      sale_columns = [["店舗", "string"], ["セラピスト", "string"], ["予約数", "string"], ["リピート", "string"], ["売上", "amount"], ["店舗分売上", "amount"]]
      # {店舗id:{name:店舗名,users:{ユーザーID:[ユーザー名,予約数,リピート,売上,店舗分売上]...}}}のリストを作成。
      reservation_sales = {}
      user_list = {0=>"該当セラピストなし"}
      User.all_by_user(session[:user_id]).where(active_flag: 1, user_role_id: 1).each do |user|
        user_list[user.id] = user.name
      end
      Store.all_by_user(session[:user_id]).each do |store|
        tmp = {}
        tmp["users"] = {}
        user_list.each do |(user_id,user_name)|
          tmp["users"][user_id] = [user_name, 0, 0, 0, 0]
        end
        tmp["name"] = store.store_name
        reservation_sales[store.id] = tmp
      end
      reservations = Reservation.all_by_user(session[:user_id]).where(reservation_status_id: 4).where("? <= reservation_datetime", sale_datetime_from + " 0:00:00").where("reservation_datetime <= ?", sale_datetime_to + " 23:59:59")
      reservations.each do |reservation|
        user_therapist = UserTherapist.find_by(store_id: reservation.store_id, therapist_id: reservation.therapist_id)
        sum_amount = reservation.reservation_courses.sum_amount + reservation.reservation_fees.sum_amount
        sum_back_therapist_amount = reservation.reservation_courses.sum_back_therapist_amount + reservation.reservation_fees.sum_back_therapist_amount
        if user_therapist.present? then
          reservation_sales[reservation.store.id]["users"][user_therapist.user_id][1] += 1
          if reservation.reservation_type_id == 1 then
            reservation_sales[reservation.store.id]["users"][user_therapist.user_id][2] += 1
          end
          reservation_sales[reservation.store.id]["users"][user_therapist.user_id][3] += sum_amount
          reservation_sales[reservation.store.id]["users"][user_therapist.user_id][4] += sum_amount - sum_back_therapist_amount
        else
          reservation_sales[reservation.store.id]["users"][0][1] += 1
          if reservation.reservation_type_id == 1 then
            reservation_sales[reservation.store.id]["users"][0][2] += 1
          end
          reservation_sales[reservation.store.id]["users"][0][3] += sum_amount
          reservation_sales[reservation.store.id]["users"][0][4] += sum_amount - sum_back_therapist_amount
        end
      end
      reservation_sales.values.each do |reservation_sale|
        # 予約の入っているユーザーだけをリストにする。
        reservation_sale["users"].values.each do |user|
          if user[1] != 0 then
            repeat_rate = 0
            sale_rate = 0
            repeat_rate = sprintf("%.1f", user[2] * 100.0 / user[1])
            if user[3] != 0 then
              sale_rate = sprintf("%.1f", user[4] * 100.0 / user[3])
            end
            sales.push([
              reservation_sale["name"],
              user[0],
              user[1],
              number_format(user[2]) + " (" + repeat_rate.to_s + "%)",
              user[3],
              number_format(user[4]) + " (" + sale_rate.to_s + "%)",
            ])
          end
        end
      end
    end

    return {
      sale_columns:sale_columns,
      sales:sales
    }
  end
end
