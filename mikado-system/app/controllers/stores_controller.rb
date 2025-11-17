class StoresController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: [:new, :index, :edit]

  def new
    @title = "店舗新規登録"
    @store = Store.new
    if flash[:store_params] != nil then
      @store.assign_attributes(flash[:store_params])
      @store.valid?
    end
  end

  def create
    @store = Store.new(store_params)
    @store.assign_attributes(active_flag: 1)
    begin
      ActiveRecord::Base.transaction do
        # 店舗の保存。
        @store.save!
      end
      # うまく作成できたら、店舗一覧に飛ぶ。
      redirect_to("/stores")
    rescue ActiveRecord::RecordInvalid => e
      flash[:store_params] = store_params
      redirect_to("/stores/new")
    end
  end

  def index
    @title = "店舗一覧"

    @store_group_list = {}
    store_groups = StoreGroup.all
    store_groups.each do |store_group|
      @store_group_list[store_group.id] = store_group.name
    end

    @stores = Store.all_by_user(session[:user_id])
  end

  def edit
    @title = "店舗編集"

    @store = Store.find(params[:id])
    if flash[:store_params] != nil then
      @store.assign_attributes(flash[:store_params])
      @store.valid?
    end
  end

  def update
    @store = Store.find(params[:id])
    begin
      ActiveRecord::Base.transaction do
        @store.update!(store_params)
      end
      # うまく作成できたら、更新した状態を見るためにeditに戻る。
      redirect_to("/stores/"+params[:id]+"/edit")
    rescue ActiveRecord::RecordInvalid => e
      flash[:store_params] = store_params
      redirect_to("/stores/"+params[:id]+"/edit")
    end
  end

  private def store_params
    params.require(:store).permit(
      :store_name,
      :store_url,
      :store_group_id,
      :active_flag
    )
  end
end
