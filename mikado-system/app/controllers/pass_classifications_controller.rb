class PassClassificationsController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: :index

  def index
    @title = "通過区分一覧"
    @pass_classifications = PassClassification.all_by_user(session[:user_id])

    if flash[:pass_classification_id].present?
      @pass_classifications.each do |pass_classification|
        if pass_classification.id.to_s == flash[:pass_classification_id].to_s
          pass_classification.assign_attributes(flash[:pass_classification_params])
          pass_classification.valid?
        end
      end
    end

    # 新規作成用のpass_classificationを初期化
    @new_pass_classification = PassClassification.new
    if flash[:new_pass_classification_params].present?
      @new_pass_classification.assign_attributes(flash[:new_pass_classification_params])
      @new_pass_classification.valid?
    end
  end

  def create
    pass_classification = PassClassification.new(pass_classification_params)

    begin
      ActiveRecord::Base.transaction do
        pass_classification.save!
      end

      # うまく作成できたら、一覧に戻る。
      redirect_to("/pass_classifications")
    rescue ActiveRecord::RecordInvalid => e
      flash[:new_pass_classification_params] = pass_classification_params
      redirect_to("/pass_classifications")
    end
  end

  def update
    pass_classification = PassClassification.find(params[:id])
    begin
      ActiveRecord::Base.transaction do
        pass_classification.update!(pass_classification_params)
      end

      # うまく更新できたら、一覧に戻る。
      redirect_to("/pass_classifications")
    rescue ActiveRecord::RecordInvalid => e
      flash[:pass_classification_params] = pass_classification_params
      flash[:pass_classification_id] = params[:id]
      redirect_to("/pass_classifications")
    end
  end

  private def pass_classification_params
    params.require(:pass_classification).permit(
      :store_group_id,
      :classification_name,
      :mail_template_subject,
      :mail_template_body,
      pass_classification_fees_attributes: [
        :id,
        :fee_name,
        :amount,
        :annotation,
        :_destroy
      ]
    )
  end
end
