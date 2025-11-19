class BonusPointsController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: [:index, :new]

  def index
    @title = "ボーナスポイント一覧"

    # 非所属セラピストに向けてポイント発行する可能性もあるので、アクティブセラピストという条件以外をつけない。
    @therapist_autocomplete = []
    User.where(user_role_id: 1, active_flag: 1).each do |user|
      auto_complete = user.name
      if user.user_therapist_setting.auto_complete.present? then
        auto_complete += user.user_therapist_setting.auto_complete
      end
      @therapist_autocomplete.push([user.id, user.name, auto_complete])
    end

    # 期間の範囲を設定。(初期値は、先月の26日〜今月の25日まで)
    start_of_month = Time.current.beginning_of_month
    bonus_datetime_from = start_of_month.yesterday.strftime("%Y-%m-26")
    bonus_datetime_from = params[:bonus_datetime_from] if params[:bonus_datetime_from].present?
    bonus_datetime_to = start_of_month.strftime("%Y-%m-25")
    bonus_datetime_to = params[:bonus_datetime_to] if params[:bonus_datetime_to].present?

    @bonus_points = BonusPoint.all_by_user(session[:user_id]).where("? <= occurrence_date", bonus_datetime_from + " 0:00:00").where("occurrence_date <= ?", bonus_datetime_to + " 23:59:59")
    @bonus_points = @bonus_points.where(user_id: params[:therapist_id]) if params[:therapist_id].present?
    @bonus_points = @bonus_points.order(occurrence_date: :asc)
  end

  def new
    @title = "ボーナスポイント発行"

    @bonus_point_collection = Form::BonusPointCollection.new
    if flash[:bonus_point_collection_params] != nil then
      @bonus_point_collection.assign_attributes(flash[:bonus_point_collection_params])
      @bonus_point_collection.valid?
    end

    # ボーナスポイントのセレクトリスト
    @bonus_point_select = []
    # 初期選択状態についてのみ使用する値
    @bonus_point_detail_initial_select = []
    @bonus_point_initial_point = 0
    @bonus_point_initial_support_point = 0
    @bonus_points = Point.where(point_type: 2).includes(:point_details)
    @bonus_points.each do |bonus_point|
      tmp_bonus_point_details = []
      bonus_point.point_details.each do |point_detail|
        tmp_bonus_point_details.push([point_detail.point_detail,{data:{point:point_detail.amount,support_point:point_detail.support_amount}}])
      end
      @bonus_point_select.push([bonus_point.point_name, tmp_bonus_point_details.to_json])
      if @bonus_point_detail_initial_select == [] then
        @bonus_point_detail_initial_select = tmp_bonus_point_details
        @bonus_point_initial_point = tmp_bonus_point_details[0][1][:data][:point]
        @bonus_point_initial_support_point = tmp_bonus_point_details[0][1][:data][:support_point]
      end
    end

    @therapist_autocomplete = []
    # 非所属セラピストに向けてポイント発行する可能性もあるので、アクティブセラピストという条件以外をつけない。
    User.where(user_role_id: 1, active_flag: 1).each do |user|
      auto_complete = user.name
      if user.user_therapist_setting.auto_complete.present? then
        auto_complete += user.user_therapist_setting.auto_complete
      end
      @therapist_autocomplete.push([user.id, user.name, auto_complete])
    end
  end

  def create
    @bonus_point_collection = Form::BonusPointCollection.new(bonus_point_collection_params)

    begin
      @bonus_point_collection.save!
      # うまく作成できたら、ボーナスポイント一覧に飛ぶ。
      redirect_to("/bonus_points")
    rescue ActiveRecord::RecordInvalid => e
      flash[:bonus_point_collection_params] = bonus_point_collection_params
      redirect_to("/bonus_points/new")
    end
  end

  def destroy
    BonusPoint.find(params[:id]).delete
    # うまく削除できたら、元のurlに戻る。
    redirect_to(request.referer)
  end

  private def bonus_point_collection_params
    params.require(:form_bonus_point_collection).permit(bonus_points_attributes: [
      :register,
      :occurrence_date,
      :user_id,
      :store_group_id,
      :store_group_name,
      :bonus,
      :point,
      :support_point
    ])
  end
end
