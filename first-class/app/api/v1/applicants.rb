module V1
  class Applicants < Grape::API
    resources :applicants do
      # 各サイトの求人フォームから求人が入った時に、それを元に応募者を作成するapi
      post '/from_applicant_form' do
        begin
          createApplicant(params)
        rescue => e
          raise StandardError.new("応募者の作成に失敗しました。(" + params["email-address"][0, 4] + "...)\n応募店舗グループは\n" + Store.find(params["system-store-id"]).store_group.name + "\nです。")
        end
      end

      # フロントから叩いて、メールアドレスで検索された最新の画像を一覧で返却するためのapi
      post '/get_latest_images_from_front' do
        begin
          getLatestImagesFromFront(params[:applicantId])
        rescue => e
          raise StandardError.new("最新画像の取得に失敗しました。\n失敗したパラメータは\n" + params[:applicantId] + "\nです。")
        end
      end

      # フロントから叩いて、画像を更新するためのapi
      post '/update_image_from_front' do
        begin
          updateImageFromFront(params[:applicantId], params[:targetImage], params[:filename], params[:contentType], params[:data])
        rescue => e
          raise StandardError.new("画像の更新に失敗しました。\n失敗したパラメータは\n" + params[:targetImage] + "\n" + params[:filename] + "\n" + params[:contentType] + "\nです。")
        end
      end

      # フロントから叩いて、対応したテンプレートを返却するためのapi
      post '/get_templates' do
        begin
          getTemplates(params[:storeGroupId], params[:applicantStatusId])
        rescue => e
          raise StandardError.new("テンプレートの取得に失敗しました。\n失敗したパラメータは\n" + params[:storeGroupId].to_s + "\n" + params[:applicantStatusId].to_s + "\nです。")
        end
      end

      # フロントから叩いて、メールアドレスで検索されたやりとりの一覧を返却するためのapi
      post '/get_threads' do
        begin
          getThreads(params[:storeGroupId], params[:mailAddress], params[:start], params[:max])
        rescue => e
          raise StandardError.new("やりとりの取得に失敗しました。\n失敗したパラメータは\n" + params[:mailAddress] + "\n" + params[:start].to_s + "\n" + params[:max].to_s + "\nです。")
        end
      end

      # フロントから叩いて、thread_idを元にメッセージの一覧を返却するためのapi
      post '/get_messages' do
        begin
          getMessages(params[:storeGroupId], params[:threadId])
        rescue => e
          raise StandardError.new("メッセージの取得に失敗しました。\n失敗したパラメータは\n" + params[:threadId] + "\nです。")
        end
      end

      # フロントなどから叩いて、一括の内容を元にパラメータを返却するためのapi
      post '/get_params_from_body' do
        begin
          getParamsFromBody(params[:body])
        rescue => e
          raise StandardError.new("パラメータの作成に失敗しました。\n失敗したパラメータは\n" + params[:body] + "\nです。")
        end
      end
    end
  end
end
