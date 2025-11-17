class HomeController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in

  def root
    redirect_to("/home")
  end

  def index
    @title = "HOME"

    @reservations = Reservation.all_by_user(session[:user_id])

    # 予約日を過ぎたのに、遂行済もしくはキャンセルになっていないもの
    yesterday = Date.today - 1
    @reservations_expired_link = "/reservations?reservation_datetime_to=" + yesterday.strftime("%Y-%m-%d")
    @reservations_expired = @reservations.merge(Reservation.where("reservation_datetime < '" + yesterday.strftime("%Y-%m-%d") + " 23:59:59'").where("reservation_status_id < 3"))

    # 本日遂行される予定の予約
    @reservations_today_link = "/reservations?reservation_datetime_from=" + Date.today.strftime("%Y-%m-%d") + "&reservation_datetime_to=" + Date.today.strftime("%Y-%m-%d")
    @reservations_today = @reservations.merge(Reservation.where("reservation_datetime <= '" + Date.today.strftime("%Y-%m-%d") + " 23:59:59'").where("'" + Date.today.strftime("%Y-%m-%d") + " 0:00:00' <= reservation_datetime").where("reservation_status_id < 3"))

    # 未確定の予約
    @reservations_unsettled_link = "/reservations?unsettled=1"
    @reservations_unsettled = @reservations.merge(Reservation.where(reservation_status_id: 1))
  end
end
