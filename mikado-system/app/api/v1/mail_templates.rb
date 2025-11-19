module V1
  class MailTemplates < Grape::API
    resources :mail_templates do
      # 応募者の情報を元にメールテンプレートからsubjectとbodyを返却するためのapi
      post '/create_applicant_mail' do
        begin
          createApplicantMail(params[:subject], params[:body], params[:mailParams])
        rescue => e
          raise StandardError.new("メールテンプレートからsubjectとbodyを作成することに失敗しました。")
        end
      end
    end
  end
end
