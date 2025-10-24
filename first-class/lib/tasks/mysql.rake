namespace :mysql do
  desc "check heart beat of mysql"
  task check_heart_beat: :environment do
    result = `ping -c 1 #{ENV['DB_HOST']}`
    puts `date '+%Y/%m/%d %H:%M:%S'`
    if result.include? '1 packets transmitted, 1 received' then
      puts "mysql is alive"
      if File.exist?(".send_notification_flag") then
        sendLine("mysqlの復旧を確認しました。")
        # フラグファイルを削除。
        File.delete(".send_notification_flag")
      end
    else
      puts "mysql is dead or unreachable."
      if File.exist?(".send_notification_flag") then
        # すでに通知を送信していたら、何もしない。
      else
        sendLine("mysqlからのレスポンスがありません。ご確認をお願いいたします。")
        file = File.new(".send_notification_flag", "w")
        file.close
      end
    end
  end

  # LINEを送信。
  private def sendLine(message)
    require 'uri'
    require 'net/http'
    require 'json'

    # チャネルアクセストークンを設定。
    token_api = ENV["LINE_TOKEN_API"]
    client_id = ENV["LINE_ERROR_LOG_CLIENT_ID"]
    client_secret = ENV["LINE_ERROR_LOG_CLIENT_SECRET"]
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
    payload = {
      "to":ENV["LINE_ERROR_LOG_TARGET_ID"],
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
      error!({error: "LINEの送信に失敗しました。error:" + e.message, backtrace: e.backtrace[0]}, 500)
    end
  end
end
