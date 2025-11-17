class StoreGroupsController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: [:new, :index, :edit]

  def new
    @title = "店舗グループ新規作成"
    @store_group = StoreGroup.new
    if flash[:store_group_params] != nil then
      @store_group.assign_attributes(flash[:store_group_params])
      @store_group.valid?
    end
  end

  def create
    @store_group = StoreGroup.new(store_group_params)
    begin
      ActiveRecord::Base.transaction do
        # 店舗グループの保存。
        @store_group.save!
      end
      # うまく作成できたら、店舗グループ一覧に飛ぶ。
      redirect_to("/store_groups")
    rescue ActiveRecord::RecordInvalid => e
      flash[:store_group_params] = store_group_params
      redirect_to("/store_groups/new")
    end
  end

  def index
    @title = "店舗グループ一覧"

    @store_groups = StoreGroup.all_by_user(session[:user_id])
  end

  def edit
    @title = "店舗グループ編集"

    @store_group = StoreGroup.find(params[:id])
    if flash[:store_group_params] != nil then
      @store_group.assign_attributes(flash[:store_group_params])
      @store_group.valid?
    end
  end

  def update
    @store_group = StoreGroup.find(params[:id])
    begin
      ActiveRecord::Base.transaction do
        @store_group.update!(store_group_params)
      end

      redirect_to("/store_groups/"+params[:id]+"/edit")
    rescue ActiveRecord::RecordInvalid => e
      flash[:store_group_params] = store_group_params
      redirect_to("/store_groups/"+params[:id]+"/edit")
    end
  end

  private def store_group_params
    params.require(:store_group).permit(
      :name,
      :credit_fee_percentage,
      :mail_api,
      :mail_name,
      :mail_signature,
      :mail_transfer_bank,
      :mail_credit_1,
      :mail_credit_2,
      :line_client_id,
      :line_client_secret,
      :line_default_target_id
    )
  end
end
