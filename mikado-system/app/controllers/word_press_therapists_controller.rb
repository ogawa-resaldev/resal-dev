class WordPressTherapistsController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: :index

  def index
    @title = "未連携セラピスト一覧"

    @therapist_autocomplete = []
    User.all_by_user(session[:user_id]).where(user_role_id: 1, active_flag: 1).each do |user|
      auto_complete = user.name
      if user.user_therapist_setting.auto_complete.present? then
        auto_complete += user.user_therapist_setting.auto_complete
      end
      @therapist_autocomplete.push([user.id, user.name, auto_complete])
    end

    # 全セラピスト情報を取得
    therapists = get_therapist_list

    # 既に紐づけられているセラピストのリスト
    linked_therapists = {}
    UserTherapist.all.each do |user_therapist|
      unless linked_therapists.key?(user_therapist[:store_id]) then
        linked_therapists[user_therapist[:store_id]] = []
      end
      linked_therapists[user_therapist[:store_id]].push(user_therapist[:therapist_id])
    end

    # 未連携のセラピストのみをフィルタリング
    @unlinked_therapists = {}
    therapists.each do |store_id, store_data|
      unlinked_therapists = {}
      store_data[:therapist].each do |therapist_id, therapist_data|
        if linked_therapists.key?(store_id) then
          unless linked_therapists[store_id].include?(therapist_id)
            unlinked_therapists[therapist_id] = therapist_data
          end
        else
          unlinked_therapists[therapist_id] = therapist_data
        end
      end

      if unlinked_therapists.present?
        @unlinked_therapists[store_id] = {
          name: store_data[:name],
          therapist: unlinked_therapists
        }
      end
    end
  end

  def link
    begin
      @store_id = params[:store_id].to_i
      @therapist_id = params[:word_press_therapist_id].to_i
      notification_group_id = ""
      if params[:notification_group_id].present? then
        notification_group_id = params[:notification_group_id]
      end

      @user = User.find(params[:therapist_id])

      # 紐づけを作成
      user_therapist = UserTherapist.new(
        user_id: @user.id,
        store_id: @store_id,
        therapist_id: @therapist_id,
        notification_group_id: notification_group_id
      )
      user_therapist.save!

      # うまくリンクできたら、一覧に戻る。
      redirect_to("/word_press_therapists/")
    rescue
      # therapist_idがない場合のエラーを代入。
      if !params[:therapist_id].present? then
        flash[:error] = "紐づけるユーザーを選択してください。"
      end
      redirect_to("/word_press_therapists/")
    end
  end
end
