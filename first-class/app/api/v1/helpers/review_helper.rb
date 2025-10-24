module V1
  module Helpers
    module ReviewHelper
      # レビューを作成。(最後にstore_id, review_idを返す。)
      def createReview(href, data)
        store_id = Store.find_by(store_url: href.gsub(/review\/.*/,""))[:id]
        # セラピスト名からIDを検索するためのリスト。
        therapist_list = {}
        get_therapist_list[store_id][:therapist].each do |key,therapist|
          therapist_list[therapist[:name]] = key
        end

        review = Review.new()
        # textarea-kuchikomiが存在しないと作成エラーになるので、フラグで管理。
        no_content = false
        data.each do |data|
          case data[:name]
          when "therapist"
            review.user_id = UserTherapist.find_by(store_id: store_id, therapist_id: therapist_list[data[:value]])[:user_id]
          when "text-name"
            review.reservation_name = data[:value]
          when "email-address"
            review.reservation_mail_address = data[:value]
          when "nickname"
            review.nickname = data[:value]
          when "select-age"
            if data[:value] == "秘密" then
              # 秘密だけ、年齢秘密に変更。
              review.age = "年齢秘密"
            else
              review.age = data[:value]
            end
          when "textarea-kuchikomi"
            if data[:value] == "" then
              no_content = true
            else
              review.content = data[:value]
            end
          end
        end

        if !no_content then
          # 他パラメータの定義。
          review.post_date = Time.current
          review.display_flag = 1

          ActiveRecord::Base.transaction do
            # レビューの作成。
            review.save!
          end
          # うまく作成できたら、word_press上のレビューを更新して、idを返却。(return使うと、処理が終わってしまう。)
          ReviewsHelper.update_wp_reviews
          {
            "no_content": no_content,
            "store_id": store_id,
            "review_id": review.id
          }
        else
          {"no_content": no_content}
        end
      end

      # レビューを元にLINEを送信。
      def sendReviewLine(store_id, review)
        user_therapist = UserTherapist.find_by(user_id: review.user_id, store_id: store_id)
        store = Store.find(store_id)
        store_group = store.store_group

        message = "以下の口コミが投稿されました。"
        message = message + "\r\n\r\n店舗: " + store.store_name
        message = message + "\r\n予約名: " + review.reservation_name + "様"
        message = message + "\r\n=========="
        message = message + "\r\n" + review.formatted_review
        message = message + "\r\n=========="

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
        if user_therapist["notification_group_id"] != "" then
          push_target_id = user_therapist["notification_group_id"]
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
    end
  end
end
