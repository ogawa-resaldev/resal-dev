class ReservationsController < ApplicationController
  include ApplicationHelper
  before_action :check_logged_in
  before_action :check_user_role, only: [:new, :index, :edit]

  def new
    @title = "予約新規作成"

    @reservation = Reservation.new

    if flash[:reservation_params] != nil then
      @reservation.assign_attributes(flash[:reservation_params])
      # 未確定、未支払いで作成。
      @reservation.reservation_status_id = 2
      @reservation.paid_flag = false
      @reservation.valid?
    end

    # キャストのスペースなしidリスト
    @therapist_id_list = {}
    # 店舗ごとのセラピストのautocompleteリスト
    therapist_autocomplete_list = {}
    therapist = get_therapist_list
    therapist.each do |key,value|
      tmp_th = {}
      value[:therapist].each do |key2,value2|
        tmp_th[key2] = [key2,value2[:name],value2[:name]]
        @therapist_id_list[value2[:name]] = key2
      end
      therapist_autocomplete_list[key] = tmp_th
    end

    # セラピスト(active_flag = 1, user_role_id = 1のユーザー)を取得して、autocompleteの拡張に使用。
    User.all_by_user(session[:user_id]).where(active_flag: 1).each do |user|
      if user.user_role_id == 1 then
        if user.user_therapist_setting.auto_complete != nil && user.user_therapists != nil then
          user.user_therapists.each do |user_therapist|
            if therapist_autocomplete_list.has_key?(user_therapist.store_id) then
              if therapist_autocomplete_list[user_therapist.store_id].has_key?(user_therapist.therapist_id) then
                therapist_autocomplete_list[user_therapist.store_id][user_therapist.therapist_id][2] += user.user_therapist_setting.auto_complete
              end
            end
          end
        end
      end
    end

    # 店舗のセレクトリスト
    # 店舗のセレクトリストにdata-therapistとしてjsonにして付与。
    @store_select = []
    stores = Store.all_by_user(session[:user_id])
    stores.each do |store|
      @store_select.push([store.store_name, store.id, {data:{therapist:therapist_autocomplete_list[store.id].values.to_json}}])
    end
    @reservation_type_select = ReservationType.all.map {|reservation_type|
      [ reservation_type.type_name, reservation_type.id ]
    }
    @reservation_payment_method_select = ReservationPaymentMethod.all.map {|reservation_payment_method|
      [ reservation_payment_method.payment_method, reservation_payment_method.id ]
    }

    # 予約ポイントのセレクトリスト
    @reservation_point_select = []
    # 初期選択状態についてのみ使用する値
    @reservation_point_detail_initial_select = []
    @reservation_point_initial_point = 0
    @reservation_point_initial_support_point = 0
    @reservation_points = Point.where(point_type: 1).includes(:point_details)
    @reservation_points.each do |reservation_point|
      tmp_reservation_point_details = []
      reservation_point.point_details.each do |point_detail|
        tmp_reservation_point_details.push([point_detail.point_detail,{data:{point:point_detail.amount,support_point:point_detail.support_amount}}])
      end
      @reservation_point_select.push([reservation_point.point_name, tmp_reservation_point_details.to_json])
      if @reservation_point_detail_initial_select == [] then
        @reservation_point_detail_initial_select = tmp_reservation_point_details
        @reservation_point_initial_point = tmp_reservation_point_details[0][1][:data][:point]
        @reservation_point_initial_support_point = tmp_reservation_point_details[0][1][:data][:support_point]
      end
    end

    # 予約費用のセレクトリスト
    @reservation_cost_select = []
    # 初期選択状態についてのみ使用する値
    @reservation_cost_detail_initial_select = []
    @reservation_cost_initial_amount = 0
    @reservation_cost_initial_back_therapist_amount = 0
    # 予約費用
    @reservation_costs = ReservationCost.all.includes(:reservation_cost_details)
    @reservation_costs.each do |reservation_cost|
      tmp_reservation_cost_details = []
      reservation_cost.reservation_cost_details.each do |reservation_cost_detail|
        tmp_reservation_cost_details.push([reservation_cost_detail.cost_detail,{data:{amount:reservation_cost_detail.amount,back_therapist_amount:reservation_cost_detail.back_therapist_amount}}])
      end
      # 最初の設定
      if @reservation_cost_select == []
        @reservation_cost_detail_initial_select = tmp_reservation_cost_details
        @reservation_cost_initial_amount = tmp_reservation_cost_details[0][1][:data][:amount]
        @reservation_cost_initial_back_therapist_amount = tmp_reservation_cost_details[0][1][:data][:back_therapist_amount]
      end
      @reservation_cost_select.push([reservation_cost.cost_type, tmp_reservation_cost_details.to_json])
    end

    # コース料金のセレクトリスト
    @course_select = []
    # コース詳細からコース、時間、料金を取得するリスト
    @course_detail_list = {}
    # 初期選択状態についてのみ使用する値
    @course_detail_initial_select = []
    @course_initial_duration = 0
    @course_initial_amount = 0
    @courses = Course.all.order(:sort_order).includes(:course_details)
    @courses.each_with_index do |course,i|
      tmp_course_details = []
      course.course_details.each do |course_detail|
        @course_detail_list[course_detail.abbreviation] = {course:course.name,duration:course_detail.duration,amount:course_detail.price}
        tmp_course_details.push([course_detail.abbreviation,{data:{duration:course_detail.duration,amount:course_detail.price}}])
      end
      @course_select.push([course.name, tmp_course_details.to_json])
      if i == 0 then
        @course_detail_initial_select = tmp_course_details
        @course_initial_duration = tmp_course_details[0][1][:data][:duration]
        @course_initial_amount = tmp_course_details[0][1][:data][:amount]
      end
    end
  end

  def create
    @reservation = Reservation.new(reservation_params)

    # 確定、未支払いで作成。
    @reservation.reservation_status_id = 2
    @reservation.paid_flag = false
    @reservation.reservation_type_id = 2
    if @reservation.meeting_count + @reservation.call_count > 0
      @reservation.reservation_type_id = 1
    end
    begin
      ActiveRecord::Base.transaction do
        @reservation.save!

        # うまく作成できたら、一覧に飛ぶ。
        flash[:notice] = "作成しました。"
        redirect_to("/reservations")
      end
    rescue ActiveRecord::RecordInvalid => e
      flash[:reservation_params] = reservation_params
      flash[:alert] = "作成に失敗しました。"
      redirect_to "/reservations/new"
    end
  end

  def index
    @title = "予約一覧"

    # 店舗id, セラピストidからセラピスト名の表示に使用するリスト
    @therapist_list = {}
    therapist = get_therapist_list
    therapist.each do |key,value|
      tmp_th = {}
      value[:therapist].each do |key2,value2|
        # ユーザーセラピストの設定だけ残っているパターンを除く
        if value2.present? then
          tmp_th[key2] = value2[:name]
        end
      end
      @therapist_list[key] = tmp_th
    end

    # セラピスト(active_flag = 1, user_role_id = 1のユーザー)のセレクトリスト
    # (店舗のセレクトリストにdata-therapistとしてjsonにして付与)
    therapist_autocomplete_list = {all:[]}
    User.all_by_user(session[:user_id]).where(active_flag: 1).each do |user|
      if user.user_role_id == 1 then
        auto_complete = user.name
        if user.user_therapist_setting.auto_complete != nil then
          auto_complete += user.user_therapist_setting.auto_complete
        end
        therapist_autocomplete_list[:all].push([user.id, user.name, auto_complete])
        user.user_therapists.each do |user_therapist|
          if !therapist_autocomplete_list.has_key?(user_therapist.store_id) then
            therapist_autocomplete_list[user_therapist.store_id] = []
          end
          therapist_autocomplete_list[user_therapist.store_id].push([user.id, user.name, auto_complete])
        end
      end
    end

    # 店舗のセレクトリスト
    @store_select = [["指定なし", "", {data:{therapist:therapist_autocomplete_list[:all].to_json}}]]
    stores = Store.all_by_user(session[:user_id])
    stores.each do |store|
      @store_select.push([store.store_name, store.id, {data:{therapist:therapist_autocomplete_list[store.id].to_json}}])
    end

    @reservations = Reservation.all_by_user(session[:user_id])

    if params[:therapist_id].present? then
      user_therapists = UserTherapist.where(user_id: params[:therapist_id])
      if user_therapists.present? then
        # 最初のwhereだけ異なるので判定。
        is_first_filter = true
        tmp_sql = Reservation
        user_therapists.each_with_index do |user_therapist, index|
          if is_first_filter then
            tmp_sql = tmp_sql.where(store_id: user_therapist.store_id, therapist_id: user_therapist.therapist_id)
            is_first_filter = false
          else
            tmp_sql = tmp_sql.or(Reservation.where(store_id: user_therapist.store_id, therapist_id: user_therapist.therapist_id))
          end
        end
      end
      @reservations = @reservations.and(tmp_sql)
    end
    @reservations = @reservations.where(store_id: params[:store_id]) if params[:store_id].present?
    @reservations = @reservations.where("? <= reservation_datetime", params[:reservation_datetime_from] + " 0:00:00") if params[:reservation_datetime_from].present?
    @reservations = @reservations.where("reservation_datetime <= ?", params[:reservation_datetime_to] + " 23:59:59") if params[:reservation_datetime_to].present?
    # ステータスによる絞り込み。
    if !params[:unsettled].present? && !params[:settled].present? && !params[:cancelled].present? && !params[:executed].present? then
      # 最初の表示の時だけここに来る想定。
      @reservations = @reservations.where(reservation_status_id: [1,2])
    else
      status_list = []
      status_list.push(1) if params[:unsettled]
      status_list.push(2) if params[:settled]
      status_list.push(3) if params[:cancelled]
      status_list.push(4) if params[:executed]
      @reservations = @reservations.where(reservation_status_id: status_list)
    end
    order = "reservation_status_id ASC, reservation_datetime ASC"
    order = params[:sort_column] + " " + params[:sort_direction] if params[:sort_column].present?
    @reservations = @reservations.order(order)
    if params[:free_word].present?
      @reservations = @reservations.select{ |reservation|
        (reservation.name + reservation.tel + reservation.mail_address).include?(params[:free_word])
      }
    end
  end

  def edit
    @title = "予約編集"

    @reservation = Reservation.find(params[:id])
    if flash[:reservation_params] != nil then
      @reservation.assign_attributes(flash[:reservation_params])
      @reservation.valid?
      @reservation.assign_attributes(reservation_status_id: flash[:beforeReservationStatusId])
    end

    # ステータス変更可能かどうかのフラグ。予約の種々パラメータの変更可否判定に使用。
    @change_status_flag = @reservation.reservation_status_id < 3

    # 店舗ごとのセラピストのautocompleteリスト([[id,name,autocomplete]...])
    therapist_autocomplete_list = {}
    therapist = get_therapist_list
    therapist.each do |key,value|
      tmp_th = {}
      value[:therapist].each do |key2,value2|
        tmp_th[key2] = [key2,value2[:name],value2[:name]]
      end
      therapist_autocomplete_list[key] = tmp_th
    end

    # セラピスト(active_flag = 1, user_role_id = 1のユーザー)を取得して、autocompleteの拡張に使用。
    User.all_by_user(session[:user_id]).where(active_flag: 1).each do |user|
      if user.user_role_id == 1 then
        if user.user_therapist_setting.auto_complete != nil && user.user_therapists != nil then
          user.user_therapists.each do |user_therapist|
            if therapist_autocomplete_list.has_key?(user_therapist.store_id) then
              if therapist_autocomplete_list[user_therapist.store_id].has_key?(user_therapist.therapist_id) then
                therapist_autocomplete_list[user_therapist.store_id][user_therapist.therapist_id][2] += user.user_therapist_setting.auto_complete
              end
            end
          end
        end
      end
    end

    # 店舗のセレクトリスト
    # 店舗のセレクトリストにdata-therapistとしてjsonにして付与。
    @store_select = []
    stores = Store.all_by_user(session[:user_id])
    stores.each do |store|
      @store_select.push([store.store_name, store.id, {data:{therapist:therapist_autocomplete_list[store.id].values.to_json}}])
    end

    # 予約ステータスのセレクトリスト
    @status_select = []
    statuses = ReservationStatus.all
    statuses.each do |status|
     @status_select.push([status.status_name, status.id])
    end

    @reservation_type_select = ReservationType.all.map {|reservation_type|
      [ reservation_type.type_name, reservation_type.id ]
    }
    @reservation_payment_method_select = ReservationPaymentMethod.all.map {|reservation_payment_method|
      [ reservation_payment_method.payment_method, reservation_payment_method.id ]
    }

    # 予約ポイントのセレクトリスト
    @reservation_point_select = []
    # 初期選択状態についてのみ使用する値
    @reservation_point_detail_initial_select = []
    @reservation_point_initial_point = 0
    @reservation_point_initial_support_point = 0
    @reservation_points = Point.where(point_type: 1).includes(:point_details)
    @reservation_points.each do |reservation_point|
      tmp_reservation_point_details = []
      reservation_point.point_details.each do |point_detail|
        tmp_reservation_point_details.push([point_detail.point_detail,{data:{point:point_detail.amount,support_point:point_detail.support_amount}}])
      end
      @reservation_point_select.push([reservation_point.point_name, tmp_reservation_point_details.to_json])
      if @reservation_point_detail_initial_select == [] then
        @reservation_point_detail_initial_select = tmp_reservation_point_details
        @reservation_point_initial_point = tmp_reservation_point_details[0][1][:data][:point]
        @reservation_point_initial_support_point = tmp_reservation_point_details[0][1][:data][:support_point]
      end
    end

    # 予約費用のセレクトリスト
    @reservation_cost_select = []
    # 初期選択状態についてのみ使用する値
    @reservation_cost_detail_initial_select = []
    # ランク
    # @ranks = Rank.all
    # tmp_rank_details = [
    #   ["フリー", {data:{amount:0,back_therapist_amount:0}}],
    #   ["ランクなし", {data:{amount:1000,back_therapist_amount:1000}}]
    # ]
    @reservation_cost_initial_amount = 0
    @reservation_cost_initial_back_therapist_amount = 0
    # @ranks.each do |rank|
    #   tmp_rank_details.push([rank.name, {data:{amount:rank.reservation_price,back_therapist_amount:rank.reservation_price}}])
    # end
    # @reservation_cost_select.push(["指名料", tmp_rank_details.to_json])
    # @reservation_cost_detail_initial_select = tmp_rank_details
    # 予約費用
    @reservation_costs = ReservationCost.all.includes(:reservation_cost_details)
    @reservation_costs.each_with_index do |reservation_cost, i|
      tmp_reservation_cost_details = []
      reservation_cost.reservation_cost_details.each_with_index do |reservation_cost_detail,j|
        tmp_reservation_cost_details.push([reservation_cost_detail.cost_detail,{data:{amount:reservation_cost_detail.amount,back_therapist_amount:reservation_cost_detail.back_therapist_amount}}])
        if i == 0 && j == 0
          @reservation_cost_detail_initial_select = tmp_reservation_cost_details
          @reservation_cost_initial_amount = tmp_reservation_cost_details[0][1][:data][:amount]
          @reservation_cost_initial_back_therapist_amount = tmp_reservation_cost_details[0][1][:data][:back_therapist_amount]
        end
      end
      @reservation_cost_select.push([reservation_cost.cost_type, tmp_reservation_cost_details.to_json])
    end

    # コース料金のセレクトリスト
    @course_select = []
    # 初期選択状態についてのみ使用する値
    @course_detail_initial_select = []
    @course_initial_duration = 0
    @course_initial_amount = 0
    @course_therapist_back_ratio = 0
    user_therapist = UserTherapist.find_by(store_id: @reservation.store_id, therapist_id: @reservation.therapist_id)
    if user_therapist != nil then
      user_therapist_setting = UserTherapistSetting.find_by(user_id: user_therapist["user_id"])
      if user_therapist_setting != nil then
        @course_therapist_back_ratio = user_therapist_setting["therapist_back_ratio"]
      end
    end
    @courses = Course.all.includes(:course_details)
    @courses.each_with_index do |course,i|
      tmp_course_details = []
      course.course_details.each do |course_detail|
        tmp_course_details.push([course_detail.abbreviation,{data:{duration:course_detail.duration,amount:course_detail.price}}])
      end
      @course_select.push([course.name, tmp_course_details.to_json])
      if i == 0 then
        @course_detail_initial_select = tmp_course_details
        @course_initial_duration = tmp_course_details[0][1][:data][:duration]
        @course_initial_amount = tmp_course_details[0][1][:data][:amount]
      end
    end
  end

  def update
    @reservation = Reservation.find(params[:id])

    beforeReservationStatusId = @reservation.reservation_status_id
    begin
      ActiveRecord::Base.transaction do
        @reservation.update!(reservation_params)
      end

      # 更新後、メールおよびLINEを送信する。
      store_group = @reservation.store.store_group
      if params[:send_email_flag] == "1" then
        sendMail(@reservation.mail_address, store_group, params[:email_subject], params[:email_body])
      end
      if params[:send_line_flag] == "1" then
        push_target_id = store_group.line_default_target_id
        user_therapist = UserTherapist.find_by(store_id: @reservation.store_id, therapist_id: @reservation.therapist_id)
        if user_therapist != nil then
          if user_therapist["notification_group_id"] != "" then
            push_target_id = user_therapist["notification_group_id"]
          end
        end
        sendLine(push_target_id, store_group, params[:line])
      end

      # 遂行済み以外から遂行済みなら、清算を作成。
      if beforeReservationStatusId != 4 && @reservation.reservation_status_id == 4 then
        createCashFlow(@reservation)
      end

      # うまく作成できたら、更新した状態を見るためにeditに戻る。
      flash[:notice] = "更新しました。"
      redirect_to("/reservations/"+params[:id]+"/edit")
    rescue ActiveRecord::RecordInvalid => e
      flash[:reservation_params] = reservation_params
      # キャンセル/遂行済みにすると編集ができなくなってしまうので、ステータスIDをbeforeに戻すためにflashに入れて渡す。
      flash[:beforeReservationStatusId] = beforeReservationStatusId
      flash[:alert] = "更新に失敗しました。"
      redirect_to("/reservations/"+params[:id]+"/edit")
    end
  end

  def update_whiteboard
    @reservation = Reservation.find(params[:id])
    @reservation.update!(whiteboard: params[:whiteboard])

    flash[:notice] = "更新しました。"
    redirect_to(request.referer)
  end

  def change_status
    @reservation = Reservation.find(params[:id])

    beforeReservationStatusId = @reservation.reservation_status_id
    begin
      ActiveRecord::Base.transaction do
        @reservation.update!(reservation_status_id: params[:reservation_status_id])
      end
      afterReservationStatusId = @reservation.reservation_status_id

      # ステータスの更新が発生したかどうかの判別。メール送信や清算作成などの意図しない連打を防ぐため。
      if beforeReservationStatusId != afterReservationStatusId then
        # 更新後、メールおよびLINEを送信する。
        store_group = @reservation.store.store_group
        if params[:send_email_flag] == "1" then
          sendMail(@reservation.mail_address, store_group, params[:reservation_email_subject], params[:reservation_email_body])
        end
        if params[:send_line_flag] == "1" then
          push_target_id = store_group.line_default_target_id
          user_therapist = UserTherapist.find_by(store_id: @reservation.store_id, therapist_id: @reservation.therapist_id)
          if user_therapist != nil then
            if user_therapist["notification_group_id"] != "" then
              push_target_id = user_therapist["notification_group_id"]
            end
          end
          sendLine(push_target_id, store_group, params[:reservation_line])
        end

        # 遂行済み以外から遂行済みなら、清算を作成。
        if beforeReservationStatusId != 4 && @reservation.reservation_status_id == 4 then
          createCashFlow(@reservation)
        end
      end
    end

    flash[:notice] = "更新しました。"
    redirect_to(request.referer)
  end

  def back_status
    @reservation = Reservation.find(params[:id])

    beforeReservationStatusId = @reservation.reservation_status_id
    begin
      if beforeReservationStatusId == 3 then
        # キャンセルなら、未確定に戻す。
        ActiveRecord::Base.transaction do
          @reservation.update!(reservation_status_id: 1)
        end
      elsif beforeReservationStatusId == 4 then
        # 遂行済みなら、振込作成済みでなければキャッシュフローを削除して、確定(未遂行)に戻す。
        ActiveRecord::Base.transaction do
          cash_flow = CashFlow.find_by(reservation_id: @reservation.id)
          if !cash_flow.transfer_id.present? then
            CashFlow.find_by(reservation_id: @reservation.id).delete
          else
            # もしすでに振込作成済みならば、エラーを出力。
            raise "すでに振込が作成されている予約を遂行済みにしようとしたため、処理を中止します。"
          end
          @reservation.update!(reservation_status_id: 2)
        end
      end
    end

    flash[:notice] = "更新しました。"
    redirect_to(request.referer)
  end

  private def reservation_params
    # :idがないと毎回新しくレコードが作られる。
    # :_destroyがないと削除ができない。
    params.require(:reservation).permit(
      :store_id,
      :therapist_id,
      :preferred_therapist,
      :reservation_datetime,
      :name,
      :contact_method,
      :meeting_count,
      :call_count,
      :tel,
      :mail_address,
      :place,
      :address,
      :sms,
      :option,
      :ng,
      :note,
      :reservation_type_id,
      :adjustment_flag,
      :reservation_payment_method_id,
      :paid_flag,
      :reservation_status_id,
      reservation_points_attributes: [
        :id,
        :point_name,
        :point_detail,
        :point,
        :support_point,
        :_destroy
      ],
      reservation_fees_attributes: [
        :id,
        :fee_type,
        :fee_detail,
        :amount,
        :back_therapist_amount,
        :_destroy
      ],
      reservation_courses_attributes: [
        :id,
        :course,
        :course_detail,
        :duration,
        :amount,
        :back_therapist_amount,
        :_destroy
      ]
    )
  end

  # 予約を元にメールを送信。
  private def sendMail(email_address, store_group, subject, body)
    # メール送信GASの実行。
    require 'uri'
    require 'net/http'
    require 'json'

    payload = {
      # なんちゃってtoken
      token: ENV["SEND_MAIL_PESUDO_TOKEN"],
      action: "createNew",
      recipientEmailAddress: email_address,
      subject: subject,
      body: body,
      options: {
        name: store_group.mail_name
      }
    }
    headers = {
      "Content-Type":"application/json"
    }
    uri = URI.parse(store_group.mail_api)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"
    begin
      response = http.post(uri.path, payload.to_json, headers)
    rescue ActiveRecord::RecordInvalid => e
      # エラー発生したら、インターナルエラー返す。
      return error!({error: "メールの送信に失敗しました。error:" + e.message, backtrace: e.backtrace[0]}, 500)
    end
  end

  # 予約を元にLINEを送信。
  private def sendLine(push_target_id, store_group, line)
    require 'uri'
    require 'net/http'
    require 'json'

    # チャネルアクセストークンを設定。
    token_api = ENV["LINE_TOKEN_API"]
    client_id = store_group.line_client_id
    client_secret = store_group.line_client_secret
    headers = {
      "Content-Type": "application/x-www-form-urlencoded"
    }
    payload_for_token = {
      grant_type: "client_credentials",
      client_id: client_id,
      client_secret: client_secret
    }
    uri_for_token = URI.parse(token_api)
    access_token = JSON.parse(Net::HTTP.post_form(uri_for_token, payload_for_token).body)["access_token"]

    # メッセージを送信。
    push_api = ENV["LINE_PUSH_API"]
    push_target_id = push_target_id
    payload = {
      "to":push_target_id,
      "messages":[{type: "text",text: line}]
    }
    headers = {
      "Authorization": "Bearer " + access_token,
      "Content-Type":"application/json"
    }
    uri = URI.parse(push_api)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"
    begin
      response = http.post(uri.path, payload.to_json, headers)
    rescue ActiveRecord::RecordInvalid => e
      # エラー発生したら、インターナルエラー返す。
      return error!({error: "LINEの送信に失敗しました。error:" + e.message, backtrace: e.backtrace[0]}, 500)
    end
  end

  # 予約を元に清算を作成。
  private def createCashFlow(reservation)
    # 清算対象ユーザーIDの取得。
    user_id = nil
    user_therapist = UserTherapist.find_by(store_id: reservation.store_id, therapist_id: reservation.therapist_id)
    if user_therapist != nil then
      user_id = user_therapist["user_id"]
    end

    # 清算の方向と金額を設定。
    # また、支払い期限設定用の日数を設定。
    direction = nil
    amount = 0
    period = 0
    if reservation.reservation_payment_method_id == 1 then
      # 現金手渡しの場合
      # 向き先：セラピスト→店。
      # 金額：合計金額 - セラピストバック金額。
      # 支払い期限：5日後。
      direction = 1
      amount += reservation.reservation_courses.sum_amount
      amount += reservation.reservation_fees.sum_amount
      amount -= reservation.reservation_courses.sum_back_therapist_amount
      amount -= reservation.reservation_fees.sum_back_therapist_amount
      period = 5
    else
      # 現金手渡し以外の場合
      # 向き先：店→セラピスト。
      # 金額：セラピストバック金額。
      # 支払い期限：30日後。
      direction = 2
      amount += reservation.reservation_courses.sum_back_therapist_amount
      amount += reservation.reservation_fees.sum_back_therapist_amount
      period = 30
    end

    @cash_flow = CashFlow.new(
      occurrence_date: reservation.reservation_datetime,
      cash_flow_period: reservation.reservation_datetime + period * 60 * 60 * 24,
      user_id: user_id,
      store_group_id: reservation.store.store_group.id,
      reservation_id: reservation.id,
      amount: amount,
      direction: direction
    )

    @cash_flow.save!
  end
end
