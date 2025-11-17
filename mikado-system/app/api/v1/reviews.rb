module V1
  class Reviews < Grape::API
    resources :reviews do
      # 各サイトのレビューフォームからレビューが入った時に、それを元にレビューを作成するapi
      post '/from_review_form' do
        begin
          reviewInfo = createReview(params[:href], params[:data])
          if !reviewInfo[:no_content] then
            review = Review.find(reviewInfo[:review_id])
            sendReviewLine(reviewInfo[:store_id], review)
          end
        rescue => e
          raise StandardError.new("レビューの作成に失敗しました。\n対象店舗のURLは\n" + params[:href] + "\nです。\n\nエラーは以下です。\n" + e.class.to_s + "\n" + e.message.to_s)
        end
      end
    end
  end
end
