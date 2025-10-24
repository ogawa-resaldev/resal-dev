namespace :applicant do
  desc "reconcile applicants with mail"
  task reconcile: :environment do
    # リコンサイルを行うのは7:00と19:00
    time = Time.now.strftime('%H%M').to_i / 100 * 100
    cond_1 = 700 == time
    cond_2 = 1900 == time
    if cond_1 || cond_2 then
      require 'httparty'

      # 登録済みのメールアドレスリスト
      mail_address_list = []
      applicants = Applicant
      query = '"' + ENV["APPLICANT_MAIL_SEARCH_QUERY"] + '"'
      if cond_1 then
        query = query + ' AND after:' + (Date.today - 1).strftime("%Y/%m/%d")
        applicants = applicants.where("? <= created_at", (Date.today - 1).strftime("%Y-%m-%d") + " 0:00:00")
      else
        query = query + ' AND after:' + Date.today.strftime("%Y/%m/%d")
        applicants = applicants.where("? <= created_at", Date.today.strftime("%Y-%m-%d") + " 0:00:00")
      end
      applicants.each do |applicant|
        mail_address_list.push(applicant.applicant_detail.mail_address)
      end
      mail_address_list.uniq!

      # 不整合があれば、ここに記載して最後にLINE通知。
      result = ""

      StoreGroup.all.each do |store_group|
        tmp = {}

        params = {
          token: ENV["SEND_MAIL_PESUDO_TOKEN"],
          action: "getThreads",
          query: query,
          start: 0,
          max: 100
        }
        res = HTTParty.post(
          store_group.mail_api,
          headers: { 'Content-Type' => 'application/json' },
          body: params.to_json
        )
        JSON.parse(res.body).each do |res|
          tmp[res["body"].split('【 メールアドレス 】')[1].split(/\R/)[0]] = res["body"]
        end

        mail_address_list.each do |mail_address|
          if tmp.has_key?(mail_address) then
            tmp.delete(mail_address)
          end
        end

        if tmp.present? then
          result = result + "\r\n\r\n" + store_group.name
          tmp.each do |mail_address, body|
            result = result + "\r\n" + mail_address[0, 4] + "..."
            payload = {
              body: body
            }
            headers = {
              "Content-Type":"application/json"
            }
            uri = URI.parse(ENV["BASE_URL"] + "/api/v1/applicants/get_params_from_body")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = uri.scheme === "https"
            params = JSON.parse(http.post(uri.path, payload.to_json, headers).body)
            HTTParty.post(
              ENV["BASE_URL"] + "/api/v1/applicants/from_applicant_form",
              body: params
            )
          end
        end
      end
      if result != "" then
        # チャネルアクセストークンを設定。
        token_api = ENV["LINE_TOKEN_API"]
        headers = {
          "Content-Type": "application/x-www-form-urlencoded"
        }
        payload_for_token = {
          grant_type: "client_credentials",
          client_id: ENV["LINE_ERROR_LOG_CLIENT_ID"],
          client_secret: ENV["LINE_ERROR_LOG_CLIENT_SECRET"]
        }
        uri_for_token = URI.parse(token_api)
        access_token = JSON.parse(Net::HTTP.post_form(uri_for_token, payload_for_token).body)["access_token"]

        # メッセージを送信。
        push_api = ENV["LINE_PUSH_API"]
        push_target_id = ENV["LINE_ERROR_LOG_TARGET_ID"]
        payload = {
          "to":push_target_id,
          "messages":[{type: "text",text: "以下メールアドレスの応募者を登録しました。" + result}]
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
  end


  desc "notify applicant of mail and line"
  task notify: :environment do
    # 通知が行われるのは午前10時から午後10時の間に限定。
    if 955 < Time.now.strftime('%H%M').to_i && Time.now.strftime('%H%M').to_i < 2300
      require 'uri'
      require 'net/http'
      require 'json'

      time = Time.now.strftime('%H%M').to_i / 100 * 100
      today = Date.today
      # 前日の場合、target_date = today + 1
      # 当日の場合、target_date = today
      # 翌日の場合、target_date = today - 1
      # となることに注意して、offset_days + 1でindexを取る。
      dates = [
        (today + 1).strftime("%Y-%m-%d"),
        today.strftime("%Y-%m-%d"),
        (today - 1).strftime("%Y-%m-%d")
      ]
      applicant_auto_notifications = ApplicantAutoNotification.where(execute_flag: 1).where(notification_time: time)
      applicant_auto_notifications.each do |applicant_auto_notification|
        store_ids = Store.where(store_group_id: applicant_auto_notification.store_group_id).pluck(:id)
        # 以下条件の応募者が対象
        # 進行中
        # 店舗グループに属する店舗の所属を希望
        applicants = Applicant
          .where(applicant_status_id: [2, 3, 4, 5])
          .joins(:applicant_detail).where(applicant_detail: {preferred_store_id: store_ids})
        case applicant_auto_notification.target_date
        when "interview_date" then
          target_date = dates[applicant_auto_notification.offset_days.to_i + 1]
          applicants = applicants.where("? <= interview_datetime", target_date + " 0:00:00").where("interview_datetime <= ?", target_date + " 23:59:59")
        when "training_date" then
          target_date = dates[applicant_auto_notification.offset_days.to_i + 1]
          applicants = applicants.where("? <= training_datetime", target_date + " 0:00:00").where("training_datetime <= ?", target_date + " 23:59:59")
        end
        if applicants.present? then
          applicant_mail_template = ""
          if applicant_auto_notification.applicant_mail_template_id.present? then
            applicant_mail_template = ApplicantMailTemplate.find(applicant_auto_notification.applicant_mail_template_id)
          end
          applicant_line_template = ""
          if applicant_auto_notification.applicant_line_template_id.present? then
            applicant_line_template = ApplicantLineTemplate.find(applicant_auto_notification.applicant_line_template_id)
          end

          applicants.each do |applicant|
            interview_datetime = ""
            if applicant.interview_datetime.present? then
              t = applicant.interview_datetime
              interview_datetime = t.month.to_s + "/" + t.day.to_s + " " + t.hour.to_s + "時"
              if t.min != 0 then
                interview_datetime = interview_datetime + t.min.to_s + "分"
              end
            end
            interviewer_name = ""
            if applicant.interviewer.present? then
              interviewer_name = applicant.interviewer.name
            end
            professional_name = ""
            if applicant.professional_name.present? then
              professional_name = applicant.professional_name
            end
            sender_name = ""
            if applicant.interviewer.present? then
              sender_name = applicant.interviewer.name
            end
            params = {
              applicantName: applicant.applicant_detail.name,
              interviewDatetime: interview_datetime,
              interviewerName: interviewer_name,
              professionalName: professional_name,
              senderName: sender_name
            }

            store_group = applicant_auto_notification.store_group

            if applicant_mail_template.present? then
              payload = {
                subject: applicant_mail_template.mail_template_subject,
                body: applicant_mail_template.mail_template_body,
                mailParams: params
              }
              headers = {
                "Content-Type":"application/json"
              }
              uri = URI.parse(ENV["BASE_URL"] + "/api/v1/mail_templates/create_applicant_mail")
              http = Net::HTTP.new(uri.host, uri.port)
              http.use_ssl = uri.scheme === "https"

              response = JSON.parse(http.post(uri.path, payload.to_json, headers).body)
              (ApplicationController.new()).send_mail(applicant.applicant_detail.mail_address, store_group, response["subject"], response["body"])
            end

            if applicant_line_template.present? then
              push_target_id = store_group.line_default_target_id
              if applicant.notification_group_id.present? then
                push_target_id = applicant.notification_group_id
              end
              payload = {
                body: applicant_line_template.line_template_body,
                lineParams: params
              }
              headers = {
                "Content-Type":"application/json"
              }
              uri = URI.parse(ENV["BASE_URL"] + "/api/v1/line_templates/create_applicant_line")
              http = Net::HTTP.new(uri.host, uri.port)
              http.use_ssl = uri.scheme === "https"

              response = JSON.parse(http.post(uri.path, payload.to_json, headers).body)
              (ApplicationController.new()).send_line(push_target_id, store_group, response)
            end
          end
        end
      end
    end
  end
end
