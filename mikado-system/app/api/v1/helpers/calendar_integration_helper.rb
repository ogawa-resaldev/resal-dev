module V1
  module Helpers
    module CalendarIntegrationHelper
      # googleカレンダーの更新をword pressに伝播
      def propagateGoogleCalendar(params)
        require 'uri'
        require 'net/http'
        require 'json'

        # user_therapist_setting_idがなければ処理を行わない。
        if !params["user_therapist_setting_id"].present?
          return
        end

        user_therapist_setting = UserTherapistSetting.find(params["user_therapist_setting_id"])

        service = Google::Apis::CalendarV3::CalendarService.new
        service.authorization = authorize()
        begin
          response = service.list_events(
            user_therapist_setting.mail_address,
            single_events: false,
            max_results: 2500,
            sync_token: user_therapist_setting.google_calendar_sync_token
          )

          # word pressへの伝播用にitemを詰める
          update_schedules = {}
          response.items.each do |item|
            # confirmedかcancelledか(status)も、日付も時間も同じ階層で詰めてしまおう。
            # そんで、updated.to_iでソートして送ろう。
            # synctokenの更新も忘れずに！
            if item.start.date_time.nil?
              date = item.start.date
              target_hour = 8
              unix_time = date.to_time.in_time_zone.change(hour: target_hour, min: 0, sec: 0).to_i
              summary = ""
              update_schedules[item.updated.to_i] = {
                status:item.status,
                date:date.strftime('%Y-%m-%d'),
                text:item.summary.to_s,
                start:unix_time,
                end:unix_time
              }
            else
              date_time = item.start.date_time
              update_schedules[item.updated.to_i] = {
                status:item.status,
                date:date_time.strftime('%Y-%m-%d'),
                text:item.summary.to_s,
                start:date_time.to_i,
                end:item.end.date_time.to_i
              }
            end
          end
          update_schedules = update_schedules.sort_by { |k, v| k.to_i }.to_h
          user_therapist_setting.user.user_therapists.each do |user_therapist|
            Net::HTTP.post_form(URI(user_therapist.store.store_url + ENV["GOOGLE_CALENDAR_UPDATE_API_PATH"]), {
              token:ENV["GOOGLE_CALENDAR_UPDATE_TOKEN"],
              therapist_id:user_therapist.therapist_id,
              update_schedules:update_schedules.to_json
            })
          end

          # 更新がうまくいったら、nextSyncTokenを更新。
          user_therapist_setting.update!(google_calendar_sync_token: response.next_sync_token)
        rescue Google::Apis::ClientError => e
          Rails.logger.error "Error listing events: #{e.message}"
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

        # アクセストークンをフェッチ（取得）
        begin
          authorizer.fetch_access_token!
          return authorizer
        rescue => e
          Rails.logger.error "Google Calendar Service Account Authorization Error: #{e.message}"
          nil
        end
      end
    end
  end
end
