namespace :integrate_google_calendar do
  desc "set up watch channels"
  task watch: :environment do
    target = UserTherapistSetting.where(integrate_google_calendar_flag: 1)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = authorize()
    target.each do |user_therapist_setting|
      # 独自のチャネルIDを生成(一意である必要あり)
      cannel_id = SecureRandom.uuid
      # 通知チャネルオブジェクトの作成
      # 1. 5日後の時刻を計算
      expiration_time = Time.now + 5.days
      expiration_timestamp_ms = expiration_time.to_i * 1000
      channel = Google::Apis::CalendarV3::Channel.new(
        # チャンネルID
        id: SecureRandom.uuid,
        # 通知タイプは "web_hook" 固定
        type: "web_hook",
        # 通知を受け取るWebhookのHTTPS URL
        address: ENV["GOOGLE_CALENDAR_WEB_HOOK_URL"] + "?user_therapist_setting_id=" + user_therapist_setting.id.to_s,
        # 期間は5日間
        expiration: expiration_timestamp_ms
      )
      service.watch_event(
        user_therapist_setting.mail_address,
        channel,
        single_events: true
      )
    end
  end

  desc "bulk update google calendar integration"
  task bulk_update: :environment do
    require "date"
    require 'mechanize'
    require 'uri'
    require 'net/http'
    require 'json'

    payload = {}
    # 更新用にword pressに投げるスケジュールリスト。
    # { store_id => { therapist_id => date_list } }
    # date_list...{ yyyy-mm-dd => { text => {$text}, start => {$start(unix time)}, end => {$end(unix time)} } }
    update_schedules = {}
    date_list = {}
    target = UserTherapistSetting.where(integrate_google_calendar_flag: 1)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = authorize()
    target.each do |user_therapist_setting|
      # 現状を全て取得して、next_sync_tokenを設定。
      next_page_token = nil
      response = nil

      # 今日から30日間のスケジュールを取得して、word pressのスケジュールを更新。
      # 期間の定義(今日から30日間)
      start_time = Time.now.beginning_of_day # 今日の0時0分から
      end_time = (start_time + 30.days).end_of_day # 30日後の23時59分59秒まで

      begin
        loop do
          response = service.list_events(
            user_therapist_setting.mail_address,
            single_events: true,
            max_results: 2500,
            page_token: next_page_token
          )

          # 次ページが無ければループ終了
          next_page_token = response.next_page_token
          break unless next_page_token
        end
        user_therapist_setting.update!(google_calendar_sync_token: response.next_sync_token)
      rescue Google::Apis::ClientError => e
        Rails.logger.error "Error listing events: #{e.message}"
      end

      begin
        response = service.list_events(
          user_therapist_setting.mail_address,
          single_events: true,
          order_by: 'startTime',
          time_min: start_time.iso8601,
          time_max: end_time.iso8601,
          max_results: 2500,
          page_token: next_page_token
        )

        response.items.each do |item|
          date = ""
          if item.start.date_time.nil?
            date = item.start.date
            target_hour = 8
            unix_time = date.to_time.in_time_zone.change(hour: target_hour, min: 0, sec: 0).to_i
            date_list[date.strftime('%Y-%m-%d')] = {
              text:item.summary,
              start:unix_time,
              end:unix_time
            }
          else
            date_time = item.start.date_time
            date_list[date_time.strftime('%Y-%m-%d')] = {
              text:item.summary,
              start:date_time.to_i,
              end:item.end.date_time.to_i
            }
          end
        end
        user_therapist_setting.user.user_therapists.each do |user_therapist|
          if !update_schedules.key?(user_therapist.store_id)
            update_schedules[user_therapist.store_id] = {}
          end
          update_schedules[user_therapist.store_id][user_therapist.therapist_id] = date_list
        end
        update_schedules.each do |store_id, therapists|
          Net::HTTP.post_form(URI(Store.find(store_id).store_url + ENV["GOOGLE_CALENDAR_BULK_UPDATE_API_PATH"]), {
            token:ENV["GOOGLE_CALENDAR_BULK_UPDATE_TOKEN"],
            update_schedules:therapists.to_json
          })
        end
      rescue Google::Apis::ClientError => e
        Rails.logger.error "Error listing events: #{e.message}"
      end
    end
  end

  # tokenの取得。
  private def authorize()
    require 'securerandom'
    require 'googleauth'
    require 'google/apis/calendar_v3'

    key_file_path = Rails.root.join('config', 'service-account.json')
    # サービスアカウントを使用して認証情報を取得
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(key_file_path),
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY
    )

    # アクセストークンを取得
    begin
      authorizer.fetch_access_token!
      return authorizer
    rescue => e
      Rails.logger.error "Google Calendar Service Account Authorization Error: #{e.message}"
      nil
    end
  end
end
