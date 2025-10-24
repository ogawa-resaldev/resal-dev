module V1
  module Helpers
    module ReservationHelper
      # 予約を作成。(最後にidを返す。)
      def createReservation(href, data)
        store_id = Store.find_by(store_url: href.gsub(/reserve\/.*/,""))[:id]
        # セラピスト名からIDを検索するためのリスト。
        therapist_list = {}
        get_therapist_list[store_id][:therapist].each do |key,therapist|
          therapist_list[therapist[:name]] = key
        end
        # セラピストのバック率を設定。
        therapist_back_ratio = 0
        # コースkeyからコース名を検索するためのリスト。
        course_key_list = {}
        Course.all.each do |course|
          course_key_list[course[:course_key]] = course[:name]
        end
        # 予約時間。
        reservation_datetime = Time.current
        # コース検索用のリスト。[flag(コース登録するかどうか),course_name,course_detail,duration,price]を格納。
        course_list = {
          "course1":[true,"","",0,0],
          "course2":[false,false,"","",0,0],
          "course3":[false,false,"","",0,0]
        }

        reservation = Reservation.new()
        data.each do |data|
          case data[:name]
          when "text-name"
            reservation.name = data[:value]
          when "tel-phone"
            reservation.tel = data[:value]
          when "email-address"
            reservation.mail_address = data[:value]
          when "select-type"
            case data[:value]
            when "リピート指名"
              reservation.reservation_type_id = 1
              reservation.adjustment_flag = 0
            when "リピート指名(セラピストと調整済み)"
              reservation.reservation_type_id = 1
              reservation.adjustment_flag = 1
            when "初回指名"
              reservation.reservation_type_id = 2
              reservation.adjustment_flag = 0
            when "初回指名(セラピストと調整済み)"
              reservation.reservation_type_id = 2
              reservation.adjustment_flag = 1
            when "フリー"
              reservation.reservation_type_id = 3
              reservation.adjustment_flag = 0
            end
          when "text-select"
            reservation.preferred_therapist = data[:value]
            if therapist_list.has_key?(data[:value]) then
              reservation.therapist_id = therapist_list[data[:value]]
              user_therapist = UserTherapist.find_by(store_id: store_id, therapist_id: reservation.therapist_id)
              if user_therapist != nil then
                user_therapist_setting = UserTherapistSetting.find_by(user_id: user_therapist["user_id"])
                if user_therapist_setting != nil then
                  therapist_back_ratio = user_therapist_setting["therapist_back_ratio"]
                end
              end
            else
              # 以下、末尾の敬称を存在判定して、存在すれば敬称を消して再検索してみる。
              compellation_list = ["さん", "君", "くん", "ちゃん", "様", "さま"]
              compellation_list.each do |compellation|
                if data[:value] =~ /#{compellation}\Z/ then
                  without_compellation = data[:value].gsub(/#{compellation}$/, "")
                  if therapist_list.has_key?(without_compellation) then
                    reservation.therapist_id = therapist_list[without_compellation]
                    user_therapist = UserTherapist.find_by(store_id: store_id, therapist_id: reservation.therapist_id)
                    if user_therapist != nil then
                      user_therapist_setting = UserTherapistSetting.find_by(user_id: user_therapist["user_id"])
                      if user_therapist_setting != nil then
                        therapist_back_ratio = user_therapist_setting["therapist_back_ratio"]
                      end
                    end
                  end
                end
              end
            end
          when "text-sale"
            if data[:value] != "" then
              reservation.discount = data[:value]
            end
          when "reserve-date"
            date = data[:value].split("-")
            reservation_datetime = reservation_datetime.change(year: date[0], month: date[1], day: date[2])
          when "reserve-time-hour"
            reservation_datetime = reservation_datetime.change(hour: data[:value])
          when "reserve-time-min"
            reservation_datetime = reservation_datetime.change(min: data[:value])
          when "select-course"
            course_list[:course1][1] = course_key_list[data[:value]]
          when "select-course-time"
            course_list[:course1][2] = data[:value].split(",")[0]
            course_list[:course1][3] = data[:value].split(",")[1].to_i
            course_list[:course1][4] = data[:value].split(",")[2].to_i
          when "select-course2"
            if data[:value] != "" then
              course_list[:course2][0] = true
              course_list[:course2][1] = course_key_list[data[:value]]
            end
          when "select-course2-time"
            if data[:value] != "" then
              course_list[:course2][2] = data[:value].split(",")[0]
              course_list[:course2][3] = data[:value].split(",")[1].to_i
              course_list[:course2][4] = data[:value].split(",")[2].to_i
            end
          when "select-course3"
            if data[:value] != "" then
              course_list[:course3][0] = true
              course_list[:course3][1] = course_key_list[data[:value]]
            end
          when "select-course3-time"
            if data[:value] != "" then
              course_list[:course3][2] = data[:value].split(",")[0]
              course_list[:course3][3] = data[:value].split(",")[1].to_i
              course_list[:course3][4] = data[:value].split(",")[2].to_i
            end
          when "text-place"
            reservation.place = data[:value]
          when "text-address"
            reservation.address = data[:value]
          when "select-payment"
            case data[:value]
            when "現金手渡し"
              reservation.reservation_payment_method_id = 1
            when "事前振り込み"
              reservation.reservation_payment_method_id = 2
            when "クレジット(事前決済)"
              reservation.reservation_payment_method_id = 3
            when "クレジット(事前決済、※決済手数料5%を追加でご負担いただく形となります。)"
              # 本店用
              reservation.reservation_payment_method_id = 3
            end
          when "select-sms"
            reservation.sms = data[:value]
          when "text-option"
            reservation.option = data[:value]
          when "text-ng"
            reservation.ng = data[:value]
          when "textarea-section"
            reservation.note = data[:value]
          end
        end

        # 他の値の定義。
        reservation.store_id = store_id
        reservation.reservation_datetime = reservation_datetime
        reservation.reservation_status_id = 1
        reservation.paid_flag = 0

        # 費用計算。
        reservationCourses = []
        eligibleForDiscount = false
        course_list.each do |key,course|
          if course[0] then
            reservationCourses.push({
              "course"=>course[1],
              "courseDetail"=>course[2],
              "courseDuration"=>course[3],
              "coursePrice"=>course[4]
            })
            if course[1] != "デートコース" && course[1] != "通話コース" && course[2] != "応援"
              eligibleForDiscount = true
            end
          end
        end
        reservation_fee_list = calcFees(reservation_datetime, reservationCourses, reservation.reservation_type_id, reservation.store_id, reservation.therapist_id)
        reservation_fee_list.push(["割引",reservation.discount,0,0]) if reservation.discount.present? && eligibleForDiscount

        ActiveRecord::Base.transaction do
          # クレジット手数料の算出用に合計料金を計算。
          sum_amount = 0

          # コース料金をreservationに追加。
          reservation_courses_attributes = {}
          reservation_courses_for_calc_points = []
          course_list.each_with_index do |(key,course),index|
            if course[0] then
              sum_amount = sum_amount + course[4]
              reservation_courses_attributes[index] = {
                course: course[1],
                course_detail: course[2],
                duration: course[3],
                amount: course[4],
                back_therapist_amount: (course[4] * therapist_back_ratio / 100).round(-2)
              }
              reservation_courses_for_calc_points.push({
                "course" => course[1],
                "course_detail" => course[2]
              })
            end
          end
          reservation.assign_attributes(reservation_courses_attributes: reservation_courses_attributes)

          # クレジット手数料
          if reservation.reservation_payment_method_id == 3 then
            reservation_fee_list.each do |fee|
              sum_amount = sum_amount + fee[2]
            end
            credit_fee = calcCreditFee(sum_amount, reservation.store_id)
            if credit_fee.present? then
              reservation_fee_list.push(calcCreditFee(sum_amount, reservation.store_id))
            end
          end

          # 予約費用をreservationに追加。
          reservation_fees_attributes = {}
          reservation_fees_for_calc_points = []
          reservation_fee_list.each_with_index do |fee,index|
            reservation_fees_attributes[index] = {
              fee_type: fee[0],
              fee_detail: fee[1],
              amount: fee[2],
              back_therapist_amount: fee[3]
            }
            reservation_fees_for_calc_points.push({
              "fee_type" => fee[0],
              "fee_detail" => fee[1]
            })
          end
          reservation.assign_attributes(reservation_fees_attributes: reservation_fees_attributes)

          # ポイントをreservationに追加。
          reservation_points_attributes = {}
          calcPoints(reservation_courses_for_calc_points, reservation_fees_for_calc_points, reservation.tel, reservation.mail_address, reservation.store_id, reservation.therapist_id).each_with_index do |point,index|
            reservation_points_attributes[index] = {
              point_name: point[0],
              point_detail: point[1],
              point: point[2],
              support_point: point[3]
            }
          end
          reservation.assign_attributes(reservation_points_attributes: reservation_points_attributes)

          # 予約の保存。
          reservation.save!
        end
        # うまく作成できたら、idを返却。(return使うと、処理が終わってしまう。)
        reservation.id
      end

      # 予約内容から、追加する必要のある予約費用のリストを返却。
      # courseDurationの単位は「分」。
      def calcFees(reservationDatetime, reservationCourses, reservationTypeId, reservationStoreId, reservationTherapistId)
        reservationFeeList = []

        # コースの時間(分)
        courseDuration = 0
        # コースおよび費用の合計料金(クレジット手数料算出用)
        sumAmount = 0
        # 割引の適用フラグ
        eligibleForDiscount = false
        # 通話コースのみのフラグ
        onlyTelCourse = true
        # 応援コースのみのフラグ
        onlySupportCourse = true
        reservationCourses.each do |reservation_course|
          case reservation_course["course"]
          when "デートコース" then
            onlyTelCourse = false
            onlySupportCourse = false
          when "通話コース" then
            onlySupportCourse = false
          when "その他" then
            if reservation_course["courseDetail"] == "応援" then
              onlyTelCourse = false
            else
              eligibleForDiscount = true
              onlyTelCourse = false
              onlySupportCourse = false
            end
          else
            eligibleForDiscount = true
            onlyTelCourse = false
            onlySupportCourse = false
          end
          courseDuration += reservation_course["courseDuration"].to_i
          sumAmount += reservation_course["coursePrice"].to_i
        end

        # 深夜料金、事前指名料の計算。
        if reservationDatetime.present? then
          # 深夜料金の有無確認用に、開始時刻と終了時刻を計算。
          reservationTime = reservationDatetime.strftime('%H%M').to_i
          endReservationTime = (reservationDatetime + courseDuration * 60).strftime('%H%M').to_i

          # 応援コース以外が存在する場合に、深夜料金を計算する。
          if !onlySupportCourse then
            if onlyTelCourse then
              # 通話コースのみの場合の深夜料金計算
              # 条件：開始時間か終了時間が1:00〜6:00
              case_1 = 100 <= reservationTime && reservationTime <= 600
              case_2 = 100 <= endReservationTime && endReservationTime <= 600
              if case_1 || case_2 then
                reservationFeeList.push(["深夜料金(通話コース)","",1000,1000])
              end
            else
              # 通話コース以外のコースがある場合の深夜料金計算
              # 条件：開始時間が0:30〜6:00 もしくは 終了時間が23:01〜6:00(=終了時間が23:01〜23:59 もしくは 0:00〜6:00)
              case_1 = 30 <= reservationTime && reservationTime <= 600
              case_2_1 = 2301 <= endReservationTime && endReservationTime <= 2359
              case_2_2 = 0 <= endReservationTime && endReservationTime <= 600
              if case_1 || case_2_1 || case_2_2 then
                costType = "深夜料金"
                lateNight = ReservationCostDetail.find_by(reservation_cost_id: ReservationCost.find_by(cost_type: costType)[:id])
                reservationFeeList.push([costType,lateNight[:cost_detail],lateNight[:amount],lateNight[:back_therapist_amount]])
              end
            end
          end

          # 事前指名料金の有無確認。
          # 条件：2週間よりも先の予約 かつ　指名タイプがフリー以外の場合
          if ((reservationDatetime - Time.current) / (60 * 60 * 24)).round(0) > 14 && reservationTypeId.to_i != 3 then
            costType = "事前指名料金"
            advanced = ReservationCostDetail.find_by(reservation_cost_id: ReservationCost.find_by(cost_type: costType)[:id])
            reservationFeeList.push([costType,advanced[:cost_detail],advanced[:amount],advanced[:back_therapist_amount]])
          end
        end

        # 指名料、新人割の計算。
        if reservationStoreId.present? && reservationTherapistId.present? then
          userTherapist = UserTherapist.find_by(store_id: reservationStoreId, therapist_id: reservationTherapistId)
          # ユーザーセラピストが登録されていたら、以降の処理を実施。
          if userTherapist.present? then
            userTherapistSetting = UserTherapistSetting.find_by(user_id: UserTherapist.find_by(store_id: reservationStoreId, therapist_id: reservationTherapistId)[:user_id])
            # 新人割の適用。
            if userTherapistSetting[:new_face] && eligibleForDiscount then
              costType = "割引"
              costDetail = "新人割"
              newFaceDiscount = ReservationCostDetail.find_by(reservation_cost_id: ReservationCost.find_by(cost_type: costType)[:id], cost_detail: costDetail)
              reservationFeeList.push([costType, costDetail, newFaceDiscount[:amount], newFaceDiscount[:back_therapist_amount]])
            end

            # 指名料の適用。(応援コースだけなら指名料を入れない。)
            if !onlySupportCourse then
              rankDetail = "フリー"
              price = 0
              # 指名タイプがフリー以外の場合
              if reservationTypeId.to_i != 3 then
                if userTherapistSetting[:rank_id] != nil then
                  rank = Rank.find(userTherapistSetting[:rank_id])
                  rankDetail = rank[:name]
                  price = rank[:reservation_price]
                else
                  rankDetail = "ランクなし"
                  price = 1000
                end
              end
              reservationFeeList.push(["指名料",rankDetail,price,price])
            end
          end
        end

        return reservationFeeList
      end

      # 予約のコース料金、予約費用の合計からクレジット手数料を算出。
      def calcCreditFee(sumAmount, reservationStoreId)
        creditFeePercentage = Store.find(reservationStoreId).store_group.credit_fee_percentage
        if creditFeePercentage != 0 then
          return ["クレジット手数料",creditFeePercentage.to_s + "%",(sumAmount.to_f * creditFeePercentage.to_f / 100.to_f).round(0),0]
        else
          return nil
        end
      end

      # 予約内容から、追加する必要のある予約ポイントのリストを返却。
      def calcPoints(reservationCourses, reservationFees, reservationTel, reservationMailAddress, reservationStoreId, reservationTherapistId)
        reservationPointList = []

        # リピートフラグ。過去の予約を確認して、電話番号かメールアドレスが一致すればリピーター判定。
        repeatFlag = false
        user_therapist = UserTherapist.find_by(store_id: reservationStoreId, therapist_id: reservationTherapistId)
        if user_therapist.present? then
          user_therapists = UserTherapist.where(user_id: user_therapist.user_id)
          user_therapists.each do |user_therapist|
            Reservation.where(store_id: user_therapist.store_id, therapist_id: user_therapist.therapist_id, reservation_status_id: '4').each do |reservation|
              if reservation[:tel] == reservationTel || reservation[:mail_address] == reservationMailAddress then
                repeatFlag = true
              end
            end
          end
        end

        # コースからリピートのポイントを計算。
        if repeatFlag then
          reservationCourses.each do |reservationCourse|
            course_point = Point.find_by(point_name: reservationCourse["course"], point_type: 1)
            if course_point.present? then
              course_point_detail = PointDetail.find_by(point_id:course_point[:id],point_detail:reservationCourse["course_detail"])
              if course_point_detail.present? then
                reservationPointList.push([course_point[:point_name],course_point_detail[:point_detail],course_point_detail[:amount],course_point_detail[:support_amount]])
              end
            end
          end
        end

        # 費用から応援ポイントを計算。
        reservationFees.each do |reservationFee|
          fee_support_point = Point.find_by(point_name: reservationFee["fee_type"], point_type: 1)
          if fee_support_point.present? then
            fee_support_point_detail = PointDetail.find_by(point_id:fee_support_point[:id],point_detail:reservationFee["fee_detail"])
            if fee_support_point_detail.present? then
              reservationPointList.push([fee_support_point[:point_name],fee_support_point_detail[:point_detail],fee_support_point_detail[:amount],fee_support_point_detail[:support_amount]])
            end
          end
        end

        return reservationPointList
      end

      # 予約を元にメールを送信。
      def sendReservationMail(reservation)
        message = createMessageForReservationMail(reservation)

        store_group = reservation.store.store_group

        # ヘッダー作成。
        header = reservation.name + "様\r\n"
        header = header + "\r\n"
        header = header + "オンライン予約をご利用いただきありがとうございます。\r\n"
        header = header + "以下の内容で送信致しました。\r\n"
        header = header + "\r\n"
        header = header + "ご予約ありがとうございます。\r\n"
        header = header + "\r\n"
        header = header + "セラピストに確認の上予約確定メールを送信させていただきます。\r\n"
        header = header + "\r\n"
        header = header + "よろしくお願いします。\r\n"
        header = header + "\r\n"
        header = header + "以下、内容です。\r\n"
        header = header + "\r\n"
        header = header + "＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝\r\n"
        header = header + "\r\n"

        # フッター作成。
        footer = "\r\n"
        footer = footer + "\r\n＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝"
        footer = footer + "\r\n"
        footer = footer + "\r\n※交通費・指名料・割引額が反映されていない場合がございます。"
        footer = footer + "\r\n正確な料金のご案内については事務局からの予約完了メールをお待ちいただければと思います。"
        footer = footer + "\r\n"
        footer = footer + "\r\n" + store_group.mail_name

        # メール送信GASの実行。
        require 'uri'
        require 'net/http'
        require 'json'

        payload = {
          # なんちゃってtoken
          token: ENV["SEND_MAIL_PESUDO_TOKEN"],
          action: "createNew",
          recipientEmailAddress: reservation.mail_address,
          subject: "オンライン予約を受け付けました",
          body: header + message + footer,
          options: {
            name: store_group.mail_name
          }
        }
        headers = {
          "Content-Type":"application/json"
        }
        uri = URI.parse(store_group.mail_api)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme === "https"
        begin
          response = http.post(uri.path, payload.to_json, headers)
        rescue ActiveRecord::RecordInvalid => e
          # エラー発生したら、インターナルエラー返す。
          return error!({error: "メールの送信に失敗しました。error:" + e.message, backtrace: e.backtrace[0]}, 500)
        end
      end

      # 予約を元にLINEを送信。
      def sendReservationLine(reservation)
        store = Store.find(reservation[:store_id])
        store_group = store.store_group

        message = createMessageForReservationLine(reservation)
        message = "\r\nこちらのご予約は対応可能でしょうか？" + message
        message = store[:store_name] + "から予約が入りました。" + message

        require 'uri'
        require 'net/http'
        require 'json'

        # チャネルアクセストークンを設定。
        token_api = ENV["LINE_TOKEN_API"]
        client_id = store_group.line_client_id
        client_secret = store_group.line_client_secret
        headers = {
          "Content-Type": "application/x-www-form-urlencoded"
        }
        payload_for_token = {
          grant_type: "client_credentials",
          client_id: client_id,
          client_secret: client_secret
        }
        uri_for_token = URI.parse(token_api)
        access_token = JSON.parse(Net::HTTP.post_form(uri_for_token, payload_for_token).body)["access_token"]

        # メッセージを送信。
        push_api = ENV["LINE_PUSH_API"]
        push_target_id = store_group.line_default_target_id
        user_therapist = UserTherapist.find_by(store_id: reservation[:store_id], therapist_id: reservation[:therapist_id])
        if user_therapist != nil then
          if user_therapist["notification_group_id"] != "" then
            push_target_id = user_therapist["notification_group_id"]
          end
        end
        payload = {
          "to":push_target_id,
          "messages":[{type: "text",text: message}]
        }
        headers = {
          "Authorization": "Bearer " + access_token,
          "Content-Type":"application/json"
        }
        uri = URI.parse(push_api)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme === "https"
        begin
          response = http.post(uri.path, payload.to_json, headers)
        rescue ActiveRecord::RecordInvalid => e
          # エラー発生したら、インターナルエラー返す。
          return error!({error: "LINEの送信に失敗しました。error:" + e.message, backtrace: e.backtrace[0]}, 500)
        end
      end

      private
      def createMessageForReservationMail(reservation)
        week = ["月","火","水","木","金","土","日"][reservation[:reservation_datetime].strftime("%u").to_i - 1]
        reservation_type = ReservationType.find(reservation[:reservation_type_id])
        reservation_payment_method = ReservationPaymentMethod.find(reservation[:reservation_payment_method_id])
        message = "\r\n【 お名前 】" + reservation[:name]
        message = message + "\r\n【 電話番号 】" + reservation[:tel]
        message = message + "\r\n【 メールアドレス 】" + reservation[:mail_address]
        message = message + "\r\n【 ご指名 】" + reservation[:preferred_therapist]
        message = message + "\r\n【 予約日時 】" + reservation[:reservation_datetime].strftime("%Y/%m/%d (#{week}) %H:%M")
        message = message + "\r\n【 ご利用場所 】" + reservation[:place]
        message = message + "\r\n【 ご住所 】" + reservation[:address]
        message = message + "\r\n【 予約の種類 】" + reservation_type[:type_name]
        message = message + "（" + (reservation[:adjustment_flag] ? "調整済み": "未調整") + "）"
        message = message + "\r\n【 支払い方法 】" + reservation_payment_method[:payment_method]
        message = message + "\r\n【 SMSメッセージ 】" + reservation[:sms]
        message = message + "\r\n【 希望オプション 】" + reservation[:option]
        message = message + "\r\n【 NG 】" + reservation[:ng]
        message = message + "\r\n【 その他、ご質問等 】" + reservation[:note]

        # 料金の合計
        price_sum = 0
        # 詳細の連結
        abbr_concat = "（"

        # コース費用の追加。
        reservation_fees = ReservationFee.where(reservation_id: reservation[:id])
        reservation_fees.each do |reservation_fee|
          message = message + "\r\n【 " + reservation_fee[:fee_type]
          if reservation_fee[:fee_detail] != "" then
            message = message + " (" + reservation_fee[:fee_detail] + ")"
          end
          message = message + " 】"
          if reservation_fee[:amount] == 0 then
            message = message + "確認中"
          else
            message = message + reservation_fee[:amount].to_formatted_s(:delimited) + "円"
            price_sum = price_sum + reservation_fee[:amount]
          end
        end

        # コース料金の追加。
        reservation_courses = ReservationCourse.where(reservation_id: reservation[:id])
        reservation_courses.each_with_index do |reservation_course,index|
          price_sum = price_sum + reservation_course[:amount]

          if index == 0 then
            abbr_concat = abbr_concat + reservation_course[:course_detail]
          else
            abbr_concat = abbr_concat + "、" + reservation_course[:course_detail]
          end
        end

        message = message + "\r\n【 料金合計※ 】" + price_sum.to_formatted_s(:delimited) + "円" + abbr_concat + "）"
      end

      private
      def createMessageForReservationLine(reservation)
        week = ["月","火","水","木","金","土","日"][reservation[:reservation_datetime].strftime("%u").to_i - 1]
        reservation_type = ReservationType.find(reservation[:reservation_type_id])
        reservation_payment_method = ReservationPaymentMethod.find(reservation[:reservation_payment_method_id])
        message = "\r\n【 お名前 】" + reservation[:name]
        message = message + "\r\n【 電話番号 】" + reservation[:tel]
        message = message + "\r\n【 ご指名 】" + reservation[:preferred_therapist]
        message = message + "\r\n【 予約日時 】" + reservation[:reservation_datetime].strftime("%Y/%m/%d (#{week}) %H:%M")
        message = message + "\r\n【 ご利用場所 】" + reservation[:place]
        message = message + "\r\n【 ご住所 】" + reservation[:address]
        message = message + "\r\n【 予約の種類 】" + reservation_type[:type_name]
        message = message + "（" + (reservation[:adjustment_flag] ? "調整済み": "未調整") + "）"
        message = message + "\r\n【 支払い方法 】" + reservation_payment_method[:payment_method]
        message = message + "\r\n【 SMSメッセージ 】" + reservation[:sms]
        message = message + "\r\n【 希望オプション 】" + reservation[:option]
        message = message + "\r\n【 NG 】" + reservation[:ng]
        message = message + "\r\n【 その他、ご質問等 】" + reservation[:note]

        # 料金の合計
        price_sum = 0

        # コース費用の追加。
        reservation_fees = ReservationFee.where(reservation_id: reservation[:id])
        reservation_fees.each do |reservation_fee|
          message = message + "\r\n【 " + reservation_fee[:fee_type]
          if reservation_fee[:fee_detail] != "" then
            message = message + " (" + reservation_fee[:fee_detail] + ")"
          end
          message = message + " 】"
          if reservation_fee[:amount] == 0 then
            message = message + "確認中"
          else
            message = message + reservation_fee[:amount].to_formatted_s(:delimited) + "円"
            price_sum = price_sum + reservation_fee[:amount]
          end
        end

        # コース料金の追加。
        reservation_courses = ReservationCourse.where(reservation_id: reservation[:id])
        reservation_courses.each_with_index do |reservation_course,index|
          price_sum = price_sum + reservation_course[:amount]

          message = message + "\r\n【 コース" + (index + 1).to_s + " 】" + reservation_course[:course]
          message = message + "\r\n【 コース時間" + (index + 1).to_s + " 】" + reservation_course[:course_detail]
        end

        message = message + "\r\n【 料金合計 ※ 】" + price_sum.to_formatted_s(:delimited) + "円"
        message = message + "\r\n\r\n※交通費・指名料・割引額が反映されていない場合がございます。"
      end
    end
  end
end
