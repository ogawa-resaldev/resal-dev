class RanksController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: :edit

  def edit
    @title = "ランキング変更"

    @user_rank_reflection_date = UserRankReflectionDate.new()
    if flash[:user_rank_reflection_date] != nil then
      @user_rank_reflection_date = UserRankReflectionDate.new(flash[:user_rank_reflection_date])
      @user_rank_reflection_date.valid?
    end

    # 反映予定のランキング
    @user_rank_collection = Form::UserRankCollection.new()
    next_user_ranks = {"user_ranks_attributes"=>{}}
    for i in 0..24 do
      next_user_ranks["user_ranks_attributes"][i] = {
        "register_user"=>"",
        "user_id"=>"",
        "rank_id"=>""
      }
    end
    if UserRank.where(reflection_date: nil).count == 0 then
      # 次の反映予定ランクがなければ、現在のランキングから作成。
      UserTherapistSetting.where.not(rank_id: nil).order(rank_id: :desc).each_with_index do |user_therapist_setting, index|
        next_user_ranks["user_ranks_attributes"][index] = {
          "register_user"=>user_therapist_setting.user.name,
          "user_id"=>user_therapist_setting.user.id,
          "rank_id"=>user_therapist_setting.rank.id
        }
      end
    else
      UserRank.where(reflection_date: nil).order(rank_id: :desc).each_with_index do |user_rank, index|
        next_user_ranks["user_ranks_attributes"][index] = {
          "register_user"=>user_rank.user.name,
          "user_id"=>user_rank.user_id,
          "rank_id"=>user_rank.rank_id
        }
      end
    end
    @user_rank_collection.assign_attributes(next_user_ranks)
    if flash[:user_rank_collection_params] != nil then
      @user_rank_collection.assign_attributes(flash[:user_rank_collection_params])
      @user_rank_collection.valid?
    end

    # 現在のランキング
    @present_ranks = {}
    User.where(active_flag: 1, user_role_id: 1).each do |therapist|
      if therapist.user_therapist_setting.rank_id.present? then
        @present_ranks[therapist.id] = {
          :therapist_id=>therapist.id,
          :name=>therapist.name,
          :rank_id=>therapist.user_therapist_setting.rank_id,
          :rank=>therapist.user_therapist_setting.rank.name
        }
      end
    end
    @present_ranks = @present_ranks.sort_by { |k,a| a[:rank_id] }.reverse.to_h

    # 反映予定のランキング
    @user_ranks = UserRank.where(reflection_date: nil).order(rank_id: :desc)

    @therapist_autocomplete = []
    # 非所属セラピストに向けてランク設定する可能性もあるので、アクティブセラピストという条件以外をつけない。
    User.where(user_role_id: 1, active_flag: 1).each do |user|
      auto_complete = user.name
      if user.user_therapist_setting.auto_complete.present? then
        auto_complete += user.user_therapist_setting.auto_complete
      end
      @therapist_autocomplete.push([user.id, user.name, auto_complete])
    end

    # ランクのセレクトリスト
    @rank_select = [["指定なし",""]]
    Rank.all.each do |rank|
      @rank_select.push([rank.name, rank.id])
    end
  end

  def update_reflection_date
    @user_rank_reflection_date = UserRankReflectionDate.new({reflection_date: params[:reflection_date]})

    begin
      ActiveRecord::Base.transaction do
        UserRankReflectionDate.delete_all
        @user_rank_reflection_date.save!
      end
      # うまく作成できたら、ランキング変更に戻る。
      redirect_to("/ranks/edit")
    rescue ActiveRecord::RecordInvalid => e
      flash[:user_rank_reflection_date] = {reflection_date: params[:reflection_date]}
      redirect_to("/ranks/edit")
    end
  end

  def update_user_rank
    @user_rank_collection = Form::UserRankCollection.new(user_rank_collection_params)

    begin
      ActiveRecord::Base.transaction do
        UserRank.where(reflection_date: nil).delete_all
        @user_rank_collection.save!
      end
      # うまく作成できたら、ランキング変更に戻る。
      redirect_to("/ranks/edit")
    rescue ActiveRecord::RecordInvalid => e
      flash[:user_rank_collection_params] = user_rank_collection_params
      redirect_to("/ranks/edit")
    end
  end

  def update_target_image_urls_for_present_ranks
    RanksHelper.update_target_image_urls_for_present_ranks
    redirect_to("/ranks/edit")
  end

  def update_ranks_immediately
    RanksHelper.reflectUserRank
    redirect_to("/ranks/edit")
  end

  private def user_rank_collection_params
    params.require(:form_user_rank_collection).permit(
      user_ranks_attributes: [
        :register_user,
        :user_id,
        :rank_id
      ])
  end
end
