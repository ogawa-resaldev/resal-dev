class ApplicationController < ActionController::Base
  include SessionsHelper

  # ログイン状態を確認。ログインしていなかったらログインページに飛ばす。
  def check_logged_in
    if not logged_in? then
      redirect_to '/login';
    end
  end

  # ログインしているユーザーの権限とアクセスしているurlによっては、「権限がない」ページに飛ばす。
  def check_user_role
    no_role_result = "権限が不足しています。<br/>ブラウザバックしてください。"
    case request.fullpath
    when /\/achievement\/[0-9]*/
      if session[:user_role_id] == 1 then
        # セラピストは自身以外の実績を表示できない。
        if session[:user_id] != params[:id].to_i then
          render inline: no_role_result
        end
      end
    when "/applicant_auto_notifications"
      if session[:user_role_id] == 1 then
        # セラピストは求人自動通知の一覧表示ができない。
        render inline: no_role_result
      end
    when "/applicant_line_templates"
      if session[:user_role_id] == 1 then
        # セラピストは求人LINEテンプレートの一覧表示ができない。
        render inline: no_role_result
      end
    when "/applicant_mail_templates"
      if session[:user_role_id] == 1 then
        # セラピストは求人メールテンプレートの一覧表示ができない。
        render inline: no_role_result
      end
    when "/applicant_status_templates"
      if session[:user_role_id] == 1 then
        # セラピストは求人ステータステンプレートの一覧表示ができない。
        render inline: no_role_result
      end
    when "/applicants"
      if session[:user_role_id] == 1 then
        # セラピストは求人の一覧表示ができない。
        render inline: no_role_result
      end
    when "/applicants/new"
      if session[:user_role_id] == 1 then
        # セラピストは求人の新規作成ができない。
        render inline: no_role_result
      end
    when /\/applicants\/[0-9]*\/edit/
      if session[:user_role_id] == 1 then
        # セラピストは求人の編集ができない。
        render inline: no_role_result
      elsif session[:user_role_id] == 3 then
        # 内勤は店舗グループが異なった求人の編集ができない。
        if User.find(session[:user_id]).back_office_group.store_group.id != Applicant.find(params[:id]).applicant_detail.preferred_store.store_group.id
          render inline: no_role_result
        end
      end
    when "/bonus_points"
      if session[:user_role_id] == 1 then
        # セラピストはボーナスポイントの一覧表示ができない。
        render inline: no_role_result
      end
    when "/bonus_points/new"
      if session[:user_role_id] == 1 then
        # セラピストはボーナスポイントの新規作成ができない。
        render inline: no_role_result
      end
    when "/cash_flows/new"
      if session[:user_role_id] == 1 then
        # セラピストは清算の新規作成ができない。
        render inline: no_role_result
      end
    when "/mikado_coin_flow_requests/new"
      if session[:user_role_id] != 1 then
        # セラピスト以外は帝コイン入出庫申請ができない。
        render inline: no_role_result
      end
    when "/mikado_coin_flows"
      # セラピストおよび本部以外の内勤は帝コイン入出庫の一覧表示ができない。
      if session[:user_role_id] == 1 then
        render inline: no_role_result
      elsif session[:user_role_id] == 3 && User.find(session[:user_id]).back_office_group.store_group_id != 1 then
        render inline: no_role_result
      end
    when "/mikado_coin_flows/new"
      # セラピストおよび本部以外の内勤は帝コイン入出庫ができない。
      if session[:user_role_id] == 1 then
        render inline: no_role_result
      elsif session[:user_role_id] == 3 && User.find(session[:user_id]).back_office_group.store_group_id != 1 then
        render inline: no_role_result
      end
    when "/miscellaneous_expenses_requests/new"
      if session[:user_role_id] != 1 then
        # セラピスト以外は雑費申請ができない。
        render inline: no_role_result
      end
    when "/pass_classifications"
      if session[:user_role_id] == 1 then
        # セラピストは通過区分の一覧表示ができない。
        render inline: no_role_result
      end
    when "/points"
      if session[:user_role_id] == 1 then
        # セラピストはポイントの一覧表示ができない。
        render inline: no_role_result
      end
    when "/ranks/edit"
      # セラピストはランキング変更に遷移できない。
      if session[:user_role_id] == 1 then
        render inline: no_role_result
      end
    when "/reservations/new"
      if session[:user_role_id] == 1 then
        # セラピストは予約の新規作成ができない。
        render inline: no_role_result
      end
    when /\/reservations\/[0-9]*\/edit/
      if session[:user_role_id] == 1 then
        # セラピストは予約の編集ができない。
        render inline: no_role_result
      elsif session[:user_role_id] == 3 then
        # 内勤は店舗グループが異なった予約の編集ができない。
        if User.find(session[:user_id]).back_office_group.store_group.id != Reservation.find(params[:id]).store.store_group.id
          render inline: no_role_result
        end
      end
    when "/reviews"
      if session[:user_role_id] == 1 then
        # セラピストはレビューの一覧表示ができない。
        render inline: no_role_result
      end
    when "/reviews/new"
      if session[:user_role_id] == 1 then
        # セラピストはレビューの新規作成ができない。
        render inline: no_role_result
      end
    when "/sales"
      if session[:user_role_id] == 1 then
        # セラピストは売上の一覧表示ができない。
        render inline: no_role_result
      end
    when "/store_groups"
      if session[:user_role_id] == 1 then
        # セラピストは店舗グループの一覧表示ができない。
        render inline: no_role_result
      end
    when "/store_groups/new"
      if session[:user_role_id] != 2 then
        # 管理者以外は店舗グループの新規作成ができない。
        render inline: no_role_result
      end
    when /\/store_groups\/[0-9]*\/edit/
      if session[:user_role_id] == 1 then
        # セラピストは店舗グループの編集ができない。
        render inline: no_role_result
      elsif session[:user_role_id] == 3 then
        # 内勤は店舗グループが異なっている場合、編集ができない。
        if User.find(session[:user_id]).back_office_group.store_group.id != StoreGroup.find(params[:id]).id
          render inline: no_role_result
        end
      end
    when "/stores"
      if session[:user_role_id] == 1 then
        # セラピストは店舗の一覧表示ができない。
        render inline: no_role_result
      end
    when "/stores/new"
      if session[:user_role_id] != 2 then
        # 管理者以外は店舗の新規作成ができない。
        render inline: no_role_result
      end
    when /\/stores\/[0-9]*\/edit/
      if session[:user_role_id] == 1 then
        # セラピストは店舗の編集ができない。
        render inline: no_role_result
      elsif session[:user_role_id] == 3 then
        # 内勤は店舗グループが異なった店舗の編集ができない。
        if User.find(session[:user_id]).back_office_group.store_group.id != Store.find(params[:id]).store_group.id
          render inline: no_role_result
        end
      end
    when "/users"
      if session[:user_role_id] == 1 then
        # セラピストはユーザーの一覧表示ができない。
        render inline: no_role_result
      end
    when "/users/new"
      if session[:user_role_id] == 1 then
        # セラピストはユーザーの新規作成ができない。
        render inline: no_role_result
      end
    when /\/users\/[0-9]*\/edit/
      if session[:user_role_id] == 1 then
        # セラピストは自身以外のプロフィールの編集ができない。
        if session[:user_id] != params[:id].to_i then
          render inline: no_role_result
        end
      elsif session[:user_role_id] == 3 then
        # 内勤は、以下ユーザーのプロフィールの編集はできない。
        # 店舗グループが異なった店舗にのみ所属しているセラピスト(all_by_userで判定)
        # 管理者
        # 店舗グループが異なった内勤
        if User.find(params[:id]).user_role_id == 1 then
          if !User.all_by_user(session[:user_id]).pluck(:id).include?(params[:id].to_i) then
            render inline: no_role_result
          end
        elsif User.find(params[:id]).user_role_id == 2 then
          render inline: no_role_result
        elsif User.find(params[:id]).user_role_id == 3 then
          if User.find(session[:user_id]).back_office_group.store_group.id != User.find(params[:id]).back_office_group.store_group.id
            render inline: no_role_result
          end
        end
      end
    when "/wiki/usage/admin"
      if session[:user_role_id] == 1 || session[:user_role_id] == 3 then
        # セラピストと内勤は管理者用の説明書が表示できない。
        render inline: no_role_result
      end
    when "/wiki/usage/back_office"
      if session[:user_role_id] == 1 then
        # セラピストは内勤用の説明書が表示できない。
        render inline: no_role_result
      end
    when /\/reviews\/[0-9]*\/edit/
      if session[:user_role_id] == 1 then
        # セラピストはレビューの編集ができない。
        render inline: no_role_result
      end
    when "/word_press_therapists"
      if session[:user_role_id] == 1 then
        # セラピストは未連携word pressセラピストを一覧表示できない。
        render inline: no_role_result
      end
    end
  end

  # メール送信GASの実行。
  def send_mail(email_address, store_group, subject, body)
    require 'uri'
    require 'net/http'
    require 'json'

    payload = {
      # なんちゃってtoken
      token: ENV["SEND_MAIL_PESUDO_TOKEN"],
      action: "createNew",
      recipientEmailAddress: email_address,
      subject: subject,
      body: ApplicationController.helpers.strip_tags(body),
      options: {
        name: store_group.mail_name,
        htmlBody: body.gsub("\r\n", "<br />")
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

  # スレッド返信GASの実行。
  def reply_thread(store_group, thread_id, body)
    require 'uri'
    require 'net/http'
    require 'json'

    payload = {
      # なんちゃってtoken
      token: ENV["SEND_MAIL_PESUDO_TOKEN"],
      action: "replyThread",
      threadId: thread_id,
      body: ApplicationController.helpers.strip_tags(body),
      options: {
        name: store_group.mail_name,
        htmlBody: body.gsub("\r\n", "<br />")
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

  # LINE送信APIの実行。
  def send_line(push_target_id, store_group, line)
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
end
