class SessionsController < ApplicationController
  layout 'layout_without_login'
  def new
    @login_error = 'ログインしてください。'
  end

  def create
    user = User.where(active_flag: true).find_by(login_id: params[:session][:login_id])
    if user && user.authenticate(params[:session][:password])
      log_in user
      if user.user_role_id == 1 then
        # ログインしたユーザーがセラピストならば、予約一覧に遷移。
        redirect_to '/reservations'
      else
        redirect_to '/home'
      end
    else
      @login_error = 'ログイン情報が間違っています。'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    @login_error = 'ログアウトしました。'
    render 'new'
  end
end