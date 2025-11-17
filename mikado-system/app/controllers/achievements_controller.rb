class AchievementsController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: :show

  def show
    @title = "実績"

    # セラピスト名
    @therapist_name = User.find(params[:id])[:name]

    # expected_...は、それぞれの見込み。(未遂行予約等)
    # 売上合計
    @sale = 0
    @expected_sale = 0
    # セラピスト報酬合計
    @therapist_sale = 0
    @expected_therapist_sale = 0
    # 予約数
    @reservation_count = 0
    @expected_reservation_count = 0
    # リピート数
    @reservation_repeat_count = 0
    @expected_reservation_repeat_count = 0
    # ポイント
    @reservation_point = 0
    @expected_reservation_point = 0
    # 応援ポイント
    @reservation_support_point = 0
    @expected_reservation_support_point = 0

    # 予約お客様(遂行済みのみ)の管理用リスト
    # {お名前(name)、利用回数(count)、総額(amount)、ポイント(point)、応援ポイント(support_point)、最終利用日(last_date)}
    @customer_list = []
    # 新規
    @new_customer_count = 0
    # 期間内で新規からリピーターになった
    @new_to_repeater_count = 0
    # リピーター
    @repeater_count = 0
    # 予約内容を反映していく中で、電話番号もメールアドレスも新しいものであれば、
    # 電話番号、メールアドレス、情報リストにそれぞれ追加。(indexが担保される想定。)
    # もし電話番号かメールアドレスのどちらかが被っているリストがすでにあれば、そのindexの情報を全て更新。
    # ※予約が遂行予定日の昇順でループする前提。
    # 電話番号リスト
    phone_number_list = []
    # メールアドレスリスト
    mail_address_list = []
    # お客様情報{お名前(name)、利用回数(count)、新規予約フラグ(期間内に、新規予約したかどうか)(new_flag)、総額(amount)、ポイント(point)、応援ポイント(support_point)、最終利用日(last_date)}のリスト
    customer_list = []

    # 期間の範囲を設定。(初期値は、先月の26日〜今月の25日まで)
    start_of_month = Time.current.beginning_of_month
    target_period_from = start_of_month.yesterday.strftime("%Y-%m-26")
    target_period_from = params[:target_period_from] if params[:target_period_from].present?
    target_period_to = start_of_month.strftime("%Y-%m-25")
    target_period_to = params[:target_period_to] if params[:target_period_to].present?

    # ユーザーセラピストの数だけ予約の検索をループさせる。
    user_therapists = UserTherapist.where(user_id: params[:id])
    if user_therapists.present? then
      user_therapists.each do |user_therapist|
        reservations = Reservation.where(store_id: user_therapist[:store_id], therapist_id: user_therapist[:therapist_id]).where("? <= reservation_datetime", target_period_from + " 0:00:00").where("reservation_datetime <= ?", target_period_to + " 23:59:59").order(reservation_datetime: :asc)
        if reservations.present? then
          reservations.each do |reservation|
            if [1,2].include?(reservation.reservation_status_id) then
              # 見込み加算。
              @expected_sale += reservation.reservation_courses.sum_amount + reservation.reservation_fees.sum_amount
              @expected_therapist_sale += reservation.reservation_courses.sum_back_therapist_amount + reservation.reservation_fees.sum_back_therapist_amount
              @expected_reservation_count += 1
              if reservation.reservation_type_id == 1 then
                @expected_reservation_repeat_count += 1
              end
              @expected_reservation_point += reservation.reservation_points.sum_point
              @expected_reservation_support_point += reservation.reservation_points.sum_support_point
            elsif reservation.reservation_status_id == 4 then
              # 実績加算。
              @sale += reservation.reservation_courses.sum_amount + reservation.reservation_fees.sum_amount
              @therapist_sale += reservation.reservation_courses.sum_back_therapist_amount + reservation.reservation_fees.sum_back_therapist_amount
              @reservation_count += 1
              if reservation.reservation_type_id == 1 then
                @reservation_repeat_count += 1
              end
              @reservation_point += reservation.reservation_points.sum_point
              @reservation_support_point += reservation.reservation_points.sum_support_point

              # お客様リストの更新。
              # indexをnilで設定。電話番号かメールアドレスが見つかれば上書き。
              index = nil
              # 電話番号確認
              if phone_number_list.index(reservation[:tel]) != nil then
                index = phone_number_list.index(reservation[:tel])
              end
              # メールアドレス確認
              if mail_address_list.index(reservation[:mail_address]) != nil then
                index = mail_address_list.index(reservation[:mail_address])
              end
              if index == nil then
                # 新しいお客様情報
                phone_number_list.push(reservation[:tel])
                mail_address_list.push(reservation[:mail_address])
                new_flag = true
                if reservation[:reservation_type_id] == 1 then
                  new_flag = false
                end
                customer_list.push({
                  name: reservation[:name],
                  count: 1,
                  new_flag: new_flag,
                  amount: reservation.reservation_courses.sum_amount + reservation.reservation_fees.sum_amount,
                  point: reservation.reservation_points.sum_point,
                  support_point: reservation.reservation_points.sum_support_point,
                  last_date: reservation.reservation_datetime.strftime('%Y/%m/%d')
                })
              else
                # すでにリストにあるお客様情報
                phone_number_list[index] = reservation[:tel]
                mail_address_list[index] = reservation[:mail_address]
                customer_list[index][:name] = reservation[:name]
                customer_list[index][:count] += 1
                customer_list[index][:amount] += reservation.reservation_courses.sum_amount + reservation.reservation_fees.sum_amount
                customer_list[index][:point] += reservation.reservation_points.sum_point
                customer_list[index][:support_point] += reservation.reservation_points.sum_support_point
                customer_list[index][:last_date] = reservation.reservation_datetime.strftime('%Y/%m/%d')
              end
            end
          end
        end
      end
    end
    customer_list.each do |customer|
      if customer[:new_flag] then
        @new_customer_count += 1
        if customer[:count] > 1 then
          @new_to_repeater_count += 1
        end
      else
        @repeater_count += 1
      end

      @customer_list.push({
        name: customer[:name],
        count: customer[:count],
        amount: customer[:amount],
        point: customer[:point],
        support_point: customer[:support_point],
        last_date: customer[:last_date]
      })
    end
  end
end
