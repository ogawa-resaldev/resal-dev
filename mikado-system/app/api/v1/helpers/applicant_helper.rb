module V1
  module Helpers
    module ApplicantHelper
      # 応募者を登録。(最後に作成したapplicantを返す。)
      def createApplicant(params)
        require 'uri'
        require 'net/http'
        require 'json'

        applicant = Applicant.new
        applicant.build_applicant_detail

        applicant.applicant_status_id = 1
        applicant.applicant_store_id = params["system-store-id"]
        applicant.applicant_detail.name = params["text-name"]
        applicant.applicant_detail.tel = params["tel-phone"]
        applicant.applicant_detail.mail_address = params["email-address"]
        applicant.applicant_detail.age = params["text-age"]
        applicant.applicant_detail.height = params["text-height"]
        applicant.applicant_detail.weight = params["text-weight"]
        applicant.applicant_detail.nearest_station = params["text-station"]
        applicant.applicant_detail.education = params["text-education"]
        applicant.applicant_detail.occupation = params["text-job"]
        applicant.applicant_detail.work_frequency = params["text-frequency"]
        applicant.applicant_detail.experience_count = params["text-experience"]

        # kiwami用
        if params["experience-num"].present?
          applicant.applicant_detail.experience_count = params["experience-num"]
        end

        applicant.applicant_detail.smoking = params["text-smoking"]
        applicant.applicant_detail.has_tattoo = params["text-tattoo"]
        applicant.applicant_detail.therapist_experience = params["text-cast"]
        applicant.applicant_detail.mosaic = params["text-mosaic"]
        applicant.applicant_detail.how_to_know = params["text-where"]

        uri = URI.parse(ENV["GET_APPLICANT_PREFERRED_STORES_API"])
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme === "https"
        response = JSON.load(http.get(uri).body)
        response.each do |res|
          if params["text-shop"] == res["store_name"]
            applicant.applicant_detail.preferred_store_text = res["store_name"]
            applicant.applicant_detail.preferred_store_id = res["system_store_id"]
          end
        end

        applicant.applicant_detail.motivation = params["textarea-cause"]
        self_pr = params["textarea-appeal"]

        # 店舗別のパラメータ
        if params["text-percentage"].present?
          self_pr += "\r\n\r\n【体脂肪率】\r\n#{params["text-percentage"]}"
        end
        if params["spec-type"].present?
          self_pr += "\r\n\r\n【強み区分】\r\n#{params["spec-type"].join("、")}"
        end
        if params["spec-exp"].present?
          self_pr += "\r\n\r\n【強み詳細】\r\n#{params["spec-exp"]}"
        end
        if params["experience-exp"].present?
          self_pr += "\r\n\r\n【女性経験】\r\n#{params["experience-exp"]}"
        end

        applicant.applicant_detail.self_pr = self_pr
        applicant.applicant_detail.other_questions = params["textarea-section"]
        applicant.applicant_detail.application_date = Date.today

        # 応募者の登録
        applicant.save!

        # 画像の取得(ジョブで行う)
        ApplicantImageFetchJob.perform_later(applicant.id)

        # うまく登録できたら、そのまま返却。(return使うと、処理が終わってしまう。)
        applicant
      end


      def getLatestImagesFromFront(applicantId)
        images = Applicant.find(params[:applicantId]).getLatestImages.map do |image|
          {
            filename: image.original_filename,
            content_type: image.content_type,
            data: Base64.encode64(image.read)
          }
        end
        return images
      end


      def updateImageFromFront(applicantId, targetImage, filename, contentType, data)
        applicant = Applicant.find(applicantId)
        image = ActionDispatch::Http::UploadedFile.new(
          filename: filename,
          type: contentType,
          tempfile: StringIO.new(Base64.decode64(data))
        )
        applicant.save_uploaded_file(targetImage, image)

        # 更新後、画像表示のためにpathを返却する。
        applicant.applicant_detail[targetImage + "_path"]
      end


      # テンプレートの一覧を返却する。
      def getTemplates(store_group_id, applicant_status_id)
        result = {line:[], mail:[]}

        ApplicantStatusLineTemplate.where(store_group_id: store_group_id, applicant_status_id: applicant_status_id).each do |applicant_status_line_template|
          applicant_line_template = applicant_status_line_template.applicant_line_template
          result[:line].push({
            name:applicant_line_template.line_template_name,
            body:applicant_line_template.line_template_body,
            default_flag:applicant_status_line_template.default_flag
          })
        end
        ApplicantStatusMailTemplate.where(store_group_id: store_group_id, applicant_status_id: applicant_status_id).each do |applicant_status_mail_template|
          applicant_mail_template = applicant_status_mail_template.applicant_mail_template
          result[:mail].push({
            name:applicant_mail_template.mail_template_name,
            subject:applicant_mail_template.mail_template_subject,
            body:applicant_mail_template.mail_template_body,
            default_flag:applicant_status_mail_template.default_flag
          })
        end

        return result
      end


      # やりとりの一覧を返却する。
      def getThreads(store_group_id, mail_address, start, max)
        require 'httparty'

        params = {
          token: ENV["SEND_MAIL_PESUDO_TOKEN"],
          action: "getThreads",
          query: mail_address,
          start: start,
          max: max
        }

        res = HTTParty.post(
          StoreGroup.find(store_group_id).mail_api,
          headers: { 'Content-Type' => 'application/json' },
          body: params.to_json
        )

        return JSON.parse(res.body)
      end


      # やりとりのIDからそのメッセージの一覧を返却する。
      def getMessages(store_group_id, thread_id)
        require 'httparty'

        params = {
          token: ENV["SEND_MAIL_PESUDO_TOKEN"],
          action: "getMessages",
          threadId: thread_id
        }

        res = HTTParty.post(
          StoreGroup.find(store_group_id).mail_api,
          headers: { 'Content-Type' => 'application/json' },
          body: params.to_json
        )

        return JSON.parse(res.body)
      end


      private def get_with_redirect(uri_str, limit = 10)
        raise ArgumentError, 'HTTP redirect too deep' if limit == 0

        uri = URI(uri_str)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)

        case response
        when Net::HTTPRedirection
          location = response['location']
          puts "redirected to #{location}"
          get_with_redirect(location, limit - 1)
        else
          response
        end
      end


      # bodyからparamを取得。
      def getParamsFromBody(body)
        result = {}
        current_key = nil
        buffer = []

        body.to_s.each_line(chomp: true) do |raw|
          line = raw.delete_suffix("\r") # CRLF 対応

          if line =~ /^【(.+?)】(.*)$/
            # 直前のブロックを確定
            if current_key
              kv = getKeyValueByText(current_key, buffer.join("\n").strip)
              result[kv[:key]] = kv[:value]
            end

            current_key = Regexp.last_match(1).strip
            first_value = Regexp.last_match(2).to_s
            buffer = [first_value]
          else
            buffer << line if current_key # 見出し外は無視
          end
        end

        # 最後のブロックを確定
        if current_key
          kv = getKeyValueByText(current_key, buffer.join("\n").strip)
          result[kv[:key]] = kv[:value]
        end

        # 空値は削除
        result.delete_if { |_k, v| v.nil? || v.empty? }
        result
      end


      private def getKeyValueByText(keyText, valueText)
        case keyText
        when "メールアドレス"
          return {
            "key":"email-address",
            "value":changeStr(valueText)
          }
        when "お名前"
          return {
            "key":"text-name",
            "value":valueText
          }
        when "電話番号"
          return {
            "key":"tel-phone",
            "value":changeStr(valueText).delete("-").delete("ー")
          }
        when "年齢"
          return {
            "key":"text-age",
            "value":changeStr(valueText)
          }
        when "身長"
          return {
            "key":"text-height",
            "value":changeStr(valueText).delete("cm")
          }
        when "体重"
          return {
            "key":"text-weight",
            "value":changeStr(valueText).delete("kg")
          }
        when "最寄駅"
          return {
            "key":"text-station",
            "value":valueText
          }
        when "学歴"
          return {
            "key":"text-education",
            "value":valueText
          }
        when "職業"
          return {
            "key":"text-job",
            "value":valueText
          }
        when "出勤頻度"
          return {
            "key":"text-frequency",
            "value":valueText
          }
        when "経験人数"
          return {
            "key":"text-experience",
            "value":valueText
          }
        when "喫煙"
          return {
            "key":"text-smoking",
            "value":valueText
          }
        when "タトゥーの有無"
          return {
            "key":"text-tattoo",
            "value":valueText
          }
        when "セラピスト経験・期間は"
          return {
            "key":"text-cast",
            "value":valueText
          }
        when "モザイク"
          return {
            "key":"text-mosaic",
            "value":valueText
          }
        when "当店をどこで知りましたか？"
          return {
            "key":"text-where",
            "value":valueText
          }
        when "希望の所属店舗"
          return {
            "key":"text-shop",
            "value":valueText
          }
        when "志望動機"
          return {
            "key":"textarea-cause",
            "value":valueText
          }
        when "自己アピール"
          return {
            "key":"textarea-appeal",
            "value":valueText
          }
        when "その他、ご質問等"
          return {
            "key":"textarea-section",
            "value":valueText
          }
        when "応募店舗ID"
          return {
            "key":"system-store-id",
            "value":valueText.split(/\R/)[0]
          }
        # 店舗用パラメータ
        ## leo
        when "体脂肪率"
          return {
            "key":"text-percentage",
            "value":changeStr(valueText)
          }
        ## kiwami
        when "強み区分"
          return {
            "key":"spec-type",
            "value":valueText.split('、')
          }
        when "強み詳細"
          return {
            "key":"spec-exp",
            "value":valueText
          }
        when "女性経験"
          return {
            "key":"experience-exp",
            "value":valueText
          }
        else
          return {
            "key":keyText,
            "value":valueText
          }
        end
      end


      # 全角英数字→半角英数字(小文字)の変換メソッド
      private def changeStr(str)
        return str.tr('０-９ａ-ｚＡ-Ｚ','0-9a-za-z')
      end
    end
  end
end
