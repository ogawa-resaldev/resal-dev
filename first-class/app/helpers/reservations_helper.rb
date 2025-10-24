module ReservationsHelper
  # コース時間を加算した、予定終了時間を返す。
  def get_end_reservation_datetime(reservation)
    reservation.reservation_datetime + reservation.reservation_courses.sum_duration * 60
  end
end
