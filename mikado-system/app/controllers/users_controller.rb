class UsersController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: [:new, :index, :edit]

  def new
    @title = "ユーザー新規作成"
    @user = User.new
    if flash[:user_params] != nil then
      @user.assign_attributes(flash[:user_params])
      @user.valid?
    end
  end

  def create
    @user = User.new(user_params)
    begin
      ActiveRecord::Base.transaction do
        # ユーザー自体の保存。
        @user.save!

        # ユーザーがセラピスト権限だったら、バック率を設定。
        if @user.user_role_id == 1 then
          UserTherapistSetting.create!({
            user_id: @user.id,
            therapist_back_ratio: 45
          })
        # ユーザーが内勤権限だったら、店舗グループを設定。
        elsif @user.user_role_id == 3 then
          # ログインしているユーザーが管理者なら、store_group_id=1で登録。
          if session[:user_role_id] == 2 then
            BackOfficeGroup.create!({
              user_id: @user.id,
              store_group_id: 1
            })
          # ログインしているユーザーが内勤なら、同じグループで登録。
          else
            BackOfficeGroup.create!({
              user_id: @user.id,
              store_group_id: BackOfficeGroup.find_by(user_id: session[:user_id])[:store_group_id]
            })
          end
        end
      end
      # うまく作成できたら、ユーザー一覧に飛ぶ。
      redirect_to("/users")
    rescue ActiveRecord::RecordInvalid => e
      flash[:user_params] = user_params
      redirect_to("/users/new")
    end
  end

  def index
    @title = "ユーザー一覧"

    @user_role_list = {}
    user_roles = UserRole.all_by_user(session[:user_id])
    user_roles.each do |user_role|
      @user_role_list[user_role.id] = user_role.name
    end

    @users = User.all_by_user(session[:user_id]).where(active_flag: true)
  end

  def edit
    @title = "プロフィール"

    @user = User.find(params[:id])
    if flash[:user_params] != nil then
      @user.assign_attributes_with_user_therapists(params[:id], flash[:user_params])
      @user.valid?
    end

    # 店舗ごとのセラピストのリスト。
    @store_selects = []
    # 初期選択状態についてのみ使用する値
    @store_therapist_initial_select = []
    # すでに紐づいている店舗セラピストはリストにいれないようにするため、紐づいているセラピストの一覧を取得。
    linked_user_therapists = {}
    UserTherapist.all.each do |user_therapist|
      if !linked_user_therapists.has_key?(user_therapist.store_id) then
        linked_user_therapists[user_therapist.store_id] = []
      end
      linked_user_therapists[user_therapist.store_id].push(user_therapist.therapist_id)
    end
    # 内勤もしくは管理者の場合はセラピストの紐づけが可能。
    if @user.user_role_id == 1 && (session[:user_role_id] == 2 || session[:user_role_id] == 3) then
      therapist_select_list = {}
      therapist_list = get_all_therapist_list

      therapist_list.each do |key,value|
        tmp_th = []
        value[:therapist].each do |key2,value2|
          if linked_user_therapists.has_key?(key) then
            if !linked_user_therapists[key].include?(key2) then
              tmp_th.push([value2[:name],key2])
            end
          else
            tmp_th.push([value2[:name],key2])
          end
        end
        therapist_select_list[key] = tmp_th
      end

      store = Store.all
      store.each_with_index do |store,i|
        @store_selects.push([store[:store_name], store[:id], therapist_select_list[store[:id]].to_json])
        if i == 0 then
          @store_therapist_initial_select = therapist_select_list[store[:id]]
        end
      end
    end

    # ユーザーがセラピストの場合、帝コインの入出庫履歴を表示。
    @mikado_coin_flows = []
    if @user.user_role_id == 1 then
      balance = 0
      mikado_coin_flows = []
      MikadoCoinFlow.where(user_id: @user.id).order(:created_at).each do |mikado_coin_flow|
        coin = mikado_coin_flow.coin
        if mikado_coin_flow.direction == 2 then
          coin = coin * -1
        end
        balance = balance + coin
        mikado_coin_flows.push({
          created_at: mikado_coin_flow.created_at,
          reason: mikado_coin_flow.reason,
          coin: coin,
          balance: balance
        })
      end
      MikadoCoinFlowRequest.where(user_id: @user.id, status_id: 0).order(:created_at).each do |mikado_coin_flow_request|
        coin = mikado_coin_flow_request.coin
        if mikado_coin_flow_request.direction == 2 then
          coin = coin * -1
        end
        mikado_coin_flows.push({
          created_at: mikado_coin_flow_request.created_at,
          reason: mikado_coin_flow_request.reason + " (申請中)",
          coin: coin,
          balance: "-"
        })
      end
      @mikado_coin_flows = mikado_coin_flows.reverse
    end
  end

  def update
    @user = User.find(params[:id])
    begin
      # パスワードを暗号化するため、updateパラメータを再定義。
      tmp_user_params = user_params
      if tmp_user_params[:password_digest] == "" then
        # パスワードは、入力がなければ更新しないようにする。
        tmp_user_params[:password_digest] = @user[:password_digest]
      else
        # 暗号化して保存。
        tmp_user_params[:password_digest] = BCrypt::Password.create(tmp_user_params[:password_digest])
      end
      ActiveRecord::Base.transaction do
        # user_therapistの登録、更新および削除は、別で行わないとエラーになる。
        if tmp_user_params[:user_therapists_attributes].present? then
          tmp_user_params[:user_therapists_attributes].each do |index,user_therapists_attribute|
            user_therapist = user_therapists_attribute
            if !user_therapists_attribute[:id].present? then
              # idがなければ、新規作成。
              UserTherapist.new(
                user_id: @user.id,
                store_id: user_therapist[:store_id],
                therapist_id: user_therapist[:therapist_id],
                notification_group_id: user_therapist[:notification_group_id]
              ).save!
            else
              # idがあれば、更新もしくは削除。
              origin_user_therapist = UserTherapist.find(user_therapists_attribute[:id])
              if user_therapist[:_destroy] == "false" then
                origin_user_therapist.update!(
                  store_id: user_therapist[:store_id],
                  therapist_id: user_therapist[:therapist_id],
                  notification_group_id: user_therapist[:notification_group_id]
                )
              else
                origin_user_therapist.delete
              end
            end
            # saveもしくはupdateしたら、二重登録を行わないようにリストから削除。
            tmp_user_params[:user_therapists_attributes].delete(index)
          end
        end
        @user.update!(tmp_user_params)
      end
      if @user.user_role_id == 1 then
        # もし、セラピストであればword press上のセラピスト情報を更新。
        UsersHelper.update_wp_therapists
      end
      # うまく更新できたら、更新した状態を見るためにeditに戻る。
      redirect_to("/users/"+params[:id]+"/edit")
    rescue ActiveRecord::RecordInvalid => e
      flash[:user_params] = user_params
      redirect_to("/users/"+params[:id]+"/edit")
    end
  end

  def send_login_information
    user = User.find(params[:id])
    store_group = StoreGroup.find(params[:user]["store_group_id"])
    target_group_id = store_group.line_default_target_id
    if params[:target_group_id].present? then
      target_group_id = params[:target_group_id]
    end
    password = SecureRandom.alphanumeric(10)

    begin
      # ログイン情報を送信
      message = UsersHelper.create_login_information_message(user.name, user.login_id, password)
      send_line(target_group_id, store_group, message)
      # パスワードを更新
      user.update!(password_digest: BCrypt::Password.create(password))

      # ログイン情報送信、パスワード更新ができたら元のurlに戻る。
      redirect_to(request.referer)
    rescue ActiveRecord::RecordInvalid => e
      flash[:user_params] = user_params
      redirect_to("/users/"+params[:id]+"/edit")
    end
  end

  def inactive
    @user = User.find(params[:id])
    begin
      ActiveRecord::Base.transaction do
        @user.update!(
          login_id: Time.current.to_i.to_s + @user[:login_id],
          active_flag: false
        )
        @user.user_therapists.each do |user_therapist|
          user_therapist.delete()
        end
      end

      # うまく非アクティブにできたら、一覧に戻る。
      redirect_to("/users/")
    rescue ActiveRecord::RecordInvalid => e
      flash[:user_params] = user_params
      redirect_to("/users/"+params[:id]+"/edit")
    end
  end

  private def user_params
    params.require(:user).permit(
      :user_role_id,
      :name,
      :login_id,
      :password_digest,
      :active_flag,
      user_therapist_setting_attributes: [
        :id,
        :user_id,
        :rank_id,
        :new_face,
        :therapist_back_ratio,
        :auto_complete,
        :mail_address,
        :account_information,
        :_destroy
      ],
      user_therapists_attributes: [
        :id,
        :user_id,
        :store_id,
        :therapist_id,
        :notification_group_id,
        :_destroy
      ],
      back_office_group_attributes: [
        :id,
        :user_id,
        :store_group_id,
        :_destroy
      ]
    )
  end
end
