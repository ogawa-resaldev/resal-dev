class PointsController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: :index

  def index
    @title = "ポイント一覧"

    @points = {}
    User.where(user_role_id: 1, active_flag: 1).each do |therapist|
      @points[therapist.id] = {
        :therapist=>therapist.name,
        # ポイントの合計+応援ポイントの合計
        :sum_all=>0,
        # ポイントの合計
        :sum_point=>0,
        # 応援ポイントの合計
        :sum_support_point=>0,
        # 予約ポイントの内、ポイントの合計
        :sum_reservation_point=>0,
        # 予約ポイントの内、応援ポイントの合計
        :sum_reservation_support_point=>0,
        # 予約ポイントを店舗ごとに分けたリスト
        :reservation_point=>{},
        # ボーナスポイントの内、ポイントの合計
        :sum_bonus_point=>0,
        # ボーナスポイントの内、応援ポイントの合計
        :sum_bonus_support_point=>0
      }
    end

    # 期間の範囲を設定。(初期値は、先月の26日〜今月の25日まで)
    start_of_month = Time.current.beginning_of_month
    target_period_from = start_of_month.yesterday.strftime("%Y-%m-26")
    target_period_from = params[:target_period_from] if params[:target_period_from].present?
    target_period_to = start_of_month.strftime("%Y-%m-25")
    target_period_to = params[:target_period_to] if params[:target_period_to].present?

    # 予約ポイントの計上。(見られる店舗の範囲制限は行わない)
    reservations = Reservation.where(reservation_status_id: 4).where("? <= reservation_datetime", target_period_from + " 0:00:00").where("reservation_datetime <= ?", target_period_to + " 23:59:59")
    reservations.each do |reservation|
      user_therapist = UserTherapist.find_by(store_id: reservation.store_id, therapist_id: reservation.therapist_id)
      if user_therapist.present? then
        if reservation.reservation_points.sum_point + reservation.reservation_points.sum_support_point != 0 then
          if !@points[user_therapist.user_id][:reservation_point].include?(reservation.store_id) then
            @points[user_therapist.user_id][:reservation_point][reservation.store_id] = {
              :store_name=>reservation.store.store_name,
              :reservation_point=>0,
              :reservation_support_point=>0
            }
          end

          @points[user_therapist.user_id][:sum_all] += reservation.reservation_points.sum_point + reservation.reservation_points.sum_support_point
          @points[user_therapist.user_id][:sum_point] += reservation.reservation_points.sum_point
          @points[user_therapist.user_id][:sum_support_point] += reservation.reservation_points.sum_support_point
          @points[user_therapist.user_id][:sum_reservation_point] += reservation.reservation_points.sum_point
          @points[user_therapist.user_id][:sum_reservation_support_point] += reservation.reservation_points.sum_support_point
          @points[user_therapist.user_id][:reservation_point][reservation.store_id][:reservation_point] += reservation.reservation_points.sum_point
          @points[user_therapist.user_id][:reservation_point][reservation.store_id][:reservation_support_point] += reservation.reservation_points.sum_support_point
        end
      end
    end

    # ボーナスポイントの計上。(見られる店舗グループの範囲制限は行わない)
    bonus_points = BonusPoint.where("? <= occurrence_date", target_period_from + " 0:00:00").where("occurrence_date <= ?", target_period_to + " 23:59:59")
    bonus_points.each do |bonus_point|
      if @points.has_key?(bonus_point.user_id) then
        @points[bonus_point.user_id][:sum_all] += bonus_point.point + bonus_point.support_point
        @points[bonus_point.user_id][:sum_point] += bonus_point.point
        @points[bonus_point.user_id][:sum_support_point] += bonus_point.support_point
        @points[bonus_point.user_id][:sum_bonus_point] += bonus_point.point
        @points[bonus_point.user_id][:sum_bonus_support_point] += bonus_point.support_point
      end
    end

    # 0ポイントの要素除外
    @points.each do |therapist_id, point|
      if point[:sum_all] == 0 then
        @points.delete(therapist_id)
      end
    end

    @points = @points.sort_by { |k,a| a[:sum_all] }.reverse.to_h
  end
end
