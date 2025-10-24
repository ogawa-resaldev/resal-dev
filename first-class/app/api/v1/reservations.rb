module V1
  class Reservations < Grape::API
    resources :reservations do
      # 各サイトの予約フォームから予約が入った時に、それを元に予約を作成するapi
      post '/from_reservation_form' do
        begin
          reservation_id = createReservation(params[:href], params[:data])
          reservation = Reservation.find(reservation_id)
          sendReservationMail(reservation)
          sendReservationLine(reservation)
        rescue => e
          raise StandardError.new("予約の作成に失敗しました。\n対象店舗のURLは\n" + params[:href] + "\nです。")
        end
      end

      # フロントから叩いて、予約費用を返却するためのapi
      post '/calc_fees' do
        begin
          reservationDatetime = ""
          if !params[:reservationDateYear].blank? && !params[:reservationDateMonth].blank? && !params[:reservationDateDay].blank? && !params[:reservationTimeHour].blank? && !params[:reservationTimeMinute].blank? then
            reservationDatetime = Time.current
            reservationDatetime = reservationDatetime.change(
              year: params[:reservationDateYear],
              month: params[:reservationDateMonth],
              day: params[:reservationDateDay],
              hour: params[:reservationTimeHour],
              min: params[:reservationTimeMinute]
            )
          end
          return calcFees(
            reservationDatetime,
            params[:reservationCourses],
            params[:reservationTypeId],
            params[:reservationStoreId],
            params[:reservationTherapistId]
          )
        rescue => e
          raise e
        end
      end

      # フロントから叩いて、クレジット手数料を返却するためのapi
      post '/calc_credit_fee' do
        begin
          return calcCreditFee(
            params[:sumAmount],
            params[:reservationStoreId]
          )
        rescue => e
          raise e
        end
      end

      # フロントから叩いて、予約ポイントを返却するためのapi
      post '/calc_points' do
        begin
          return calcPoints(
            params[:reservationCourses],
            params[:reservationFees],
            params[:reservationTel],
            params[:reservationMailAddress],
            params[:reservationStoreId],
            params[:reservationTherapistId]
          )
        rescue => e
          raise e
        end
      end

      # フロントから叩いて、店舗IDとセラピストIDからセラピストバック率を返却するためのapi
      post '/get_therapist_back_ratio' do
        begin
          therapistBackRatio = 0
          userTherapist = UserTherapist.find_by(store_id: params[:reservationStoreId], therapist_id: params[:reservationTherapistId])
          if userTherapist != nil then
            userTherapistSetting = UserTherapistSetting.find_by(user_id: userTherapist[:user_id])
            if userTherapistSetting != nil then
              therapistBackRatio = userTherapistSetting[:therapist_back_ratio]
            end
          end
          return therapistBackRatio
        rescue => e
          raise e
        end
      end

      # フロントから叩いて、店舗IDからメール用のパラメータを返却するためのapi
      post '/get_mail_params' do
        begin
          store = Store.find(params[:reservationStoreId])
          store_group = store.store_group
          return {
            "name"=>store_group.mail_name,
            "signature"=>store_group.mail_signature,
            "transferBank"=>store_group.mail_transfer_bank,
            "credit1"=>store_group.mail_credit_1,
            "credit2"=>store_group.mail_credit_2,
            "reviewUrl"=>store.store_url + "review/",
          }
        rescue => e
          raise e
        end
      end
    end
  end
end
