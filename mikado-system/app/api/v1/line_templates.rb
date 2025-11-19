module V1
  class LineTemplates < Grape::API
    resources :line_templates do
      # 応募者の情報を元にLINEテンプレートからbodyを返却するためのapi
      post '/create_applicant_line' do
        begin
          createApplicantLine(params[:body], params[:lineParams])
        rescue => e
          raise StandardError.new("LINEテンプレートからbodyを作成することに失敗しました。")
        end
      end
    end
  end
end
