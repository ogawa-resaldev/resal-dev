namespace :advanced_pay do
  # 以下条件の予約について、LINE通知+ホワイトボードに内容を記載。
  # ・未確定or確定
  # ・事前振り込みorクレジット(事前決済)
  # ・開始時刻が現在+3時間より前になっている
  # ・支払い済みフラグが立っていない
  desc "advanced_pay"
  task check_paid_flag: :environment do
    # 深夜にLINE通知するのを防ぐため、確認が行われるのは午前10時から午後10時の間に限定する。
    if 955 < Time.now.strftime('%H%M').to_i && Time.now.strftime('%H%M').to_i < 2300
      store_group_list = {}
      reservations = Reservation
        .where(reservation_status_id: [1, 2])
        .where(reservation_payment_method_id: [2, 3])
        .where("reservation_datetime <= ?", (Time.now + 3 * 60 * 60).strftime("%Y-%m-%d %H:%M:%S"))
        .where(paid_flag: 0)
      if reservations.present? then
        reservations.each do |reservation|
          if !store_group_list.include?(reservation.store.store_group_id) then
            store_group = reservation.store.store_group
            store_group_list[store_group.id] = {
              line_default_target_id: store_group.line_default_target_id,
              line_client_id: store_group.line_client_id,
              line_client_secret: store_group.line_client_secret,
              line: "以下の予約にて、事前決済の確認を行なってください。"
            }
          end
          therapist_name = "未割り当て"
          therapist_name = reservation.therapist_name if reservation.therapist_name != ""
          store_group_list[reservation.store.store_group_id][:line] += "\n"
          store_group_list[reservation.store.store_group_id][:line] += "\n" + "予約受付日：" + reservation.created_at.strftime("%Y/%m/%d")
          store_group_list[reservation.store.store_group_id][:line] += "\n" + "予約日：" + reservation.reservation_datetime.strftime("%Y/%m/%d")
          store_group_list[reservation.store.store_group_id][:line] += "\n" + "セラピスト：" + therapist_name
          store_group_list[reservation.store.store_group_id][:line] += "\n" + "予約者：" + reservation.name + "様"
          store_group_list[reservation.store.store_group_id][:line] += "\n" + "電話番号：" + reservation.tel
          store_group_list[reservation.store.store_group_id][:line] += "\n" + "金額：" + (reservation.reservation_courses.sum_amount + reservation.reservation_fees.sum_amount).to_s + "円"
          store_group_list[reservation.store.store_group_id][:line] += "\n" + "決済方法：" + reservation.reservation_payment_method.payment_method
          if reservation.whiteboard.nil? then
            reservation.whiteboard = "支払い済みにチェックがありません。"
            reservation.save!()
          elsif !reservation.whiteboard.include?("支払い済みにチェックがありません。") then
            reservation.whiteboard += "\n支払い済みにチェックがありません。"
            reservation.save!()
          end
        end
      end

      store_group_list.each do |i, store_group|
        send_line(store_group[:line_default_target_id], store_group[:line_client_id], store_group[:line_client_secret], store_group[:line])
      end
    end
  end

  # LINE送信APIの実行。
  private def send_line(push_target_id, client_id, client_secret, line)
    require 'uri'
    require 'net/http'
    require 'json'

    # チャネルアクセストークンを設定。
    token_api = ENV["LINE_TOKEN_API"]
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
    push_target_id = push_target_id
    payload = {
      "to":push_target_id,
      "messages":[{type: "text",text: line}]
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
end
