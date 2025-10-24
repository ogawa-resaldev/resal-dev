Rails.application.routes.draw do
  # ルート
  root to: 'home#root'

  # ホーム
  get    '/home',   to: 'home#index'

  # 実績
  get '/achievement/:id',   to:'achievements#show'

  # 求人自動通知
  get '/applicant_auto_notifications', to: 'applicant_auto_notifications#index'
  post '/applicant_auto_notifications',   to: 'applicant_auto_notifications#create'
  patch '/applicant_auto_notifications/:id',   to: 'applicant_auto_notifications#update'

  # 求人LINEテンプレート
  get '/applicant_line_templates', to: 'applicant_line_templates#index'
  post '/applicant_line_templates',   to: 'applicant_line_templates#create'
  patch '/applicant_line_templates/:id',   to: 'applicant_line_templates#update'

  # 求人メールテンプレート
  get '/applicant_mail_templates', to: 'applicant_mail_templates#index'
  post '/applicant_mail_templates',   to: 'applicant_mail_templates#create'
  patch '/applicant_mail_templates/:id',   to: 'applicant_mail_templates#update'

  # 求人ステータス別テンプレート
  get '/applicant_status_templates', to: 'applicant_status_templates#index'
  delete '/applicant_status_templates/mail/:id',   to: 'applicant_status_templates#mail_destroy'
  delete '/applicant_status_templates/line/:id',   to: 'applicant_status_templates#line_destroy'
  resources :applicant_status_templates do
    collection do
      post :add_line_template
      post :add_mail_template
    end
    member do
      post :line_default
      post :mail_default
    end
  end

  # 求人
  get '/applicants', to: 'applicants#index'
  get '/applicants/new',   to: 'applicants#new'
  post '/applicants',   to: 'applicants#create'
  get '/applicants/:id/edit',   to: 'applicants#edit'
  patch '/applicants/:id',   to: 'applicants#update'
  delete '/applicants/:id',   to: 'applicants#destroy'
  resources :applicants do
    member do
      patch :update_pending_flag
    end
  end

  # ボーナスポイント
  get '/bonus_points',   to: 'bonus_points#index'
  get '/bonus_points/new',   to: 'bonus_points#new'
  post '/bonus_points',   to: 'bonus_points#create'
  delete '/bonus_points/:id',   to: 'bonus_points#destroy'

  # 清算
  get '/cash_flows',   to: 'cash_flows#index'
  get '/cash_flows/new',   to: 'cash_flows#new'
  post '/cash_flows',   to: 'cash_flows#create'
  delete '/cash_flows/:id',   to: 'cash_flows#destroy'

  # ログイン/ログアウト
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  get    '/logout',  to: 'sessions#destroy'

  # 帝コイン申請
  get '/mikado_coin_flow_requests/new',   to: 'mikado_coin_flow_requests#new'
  post '/mikado_coin_flow_requests',   to: 'mikado_coin_flow_requests#create'
  resources :mikado_coin_flow_requests do
    member do
      post :approve
      post :cancel
    end
  end

  # 帝コイン入出庫
  get '/mikado_coin_flows',   to: 'mikado_coin_flows#index'
  get '/mikado_coin_flows/new',   to: 'mikado_coin_flows#new'
  post '/mikado_coin_flows',   to: 'mikado_coin_flows#create'

  # 雑費申請
  get '/miscellaneous_expenses_requests/new',   to: 'miscellaneous_expenses_requests#new'
  post '/miscellaneous_expenses_requests',   to: 'miscellaneous_expenses_requests#create'
  resources :miscellaneous_expenses_requests do
    member do
      post :approve
      post :cancel
    end
  end

  # 通過区分
  get '/pass_classifications',   to: 'pass_classifications#index'
  post '/pass_classifications',   to: 'pass_classifications#create'
  patch '/pass_classifications/:id',   to: 'pass_classifications#update'

  # ポイント
  get '/points',   to: 'points#index'

  # ランキング
  get    '/ranks/edit',   to: 'ranks#edit'
  post    '/ranks/update_reflection_date',   to: 'ranks#update_reflection_date'
  post    '/ranks/update_user_rank',   to: 'ranks#update_user_rank'
  get    '/ranks/update_target_image_urls_for_present_ranks',   to: 'ranks#update_target_image_urls_for_present_ranks'
  get    '/ranks/update_ranks_immediately',   to: 'ranks#update_ranks_immediately'


  # 予約
  get '/reservations',   to: 'reservations#index'
  get '/reservations/new',   to: 'reservations#new'
  post '/reservations',   to: 'reservations#create'
  get  '/reservations/:id/edit',   to: 'reservations#edit'
  patch '/reservations/:id',   to: 'reservations#update'
  resources :reservations do
    member do
      patch :back_status
      patch :change_status
      patch :update_whiteboard
    end
  end
  put '/reservations/:id',   to: 'reservations#update'
  delete '/reservations/:id',   to: 'reservations#destroy'

  # レビュー
  get '/reviews',   to: 'reviews#index'
  get '/reviews/new',   to: 'reviews#new'
  post '/reviews',   to: 'reviews#create'
  get '/reviews/:id/edit',   to: 'reviews#edit'
  patch '/reviews/:id',   to: 'reviews#update'

  # 売上
  get '/sales',   to: 'sales#index'

  # 店舗グループ
  get '/store_groups',   to: 'store_groups#index'
  get '/store_groups/new',   to: 'store_groups#new'
  post '/store_groups',   to: 'store_groups#create'
  get '/store_groups/:id/edit',   to: 'store_groups#edit'
  patch '/store_groups/:id',   to: 'store_groups#update'

  # 店舗
  get '/stores',   to: 'stores#index'
  get '/stores/new',   to: 'stores#new'
  post '/stores',   to: 'stores#create'
  get '/stores/:id/edit',   to: 'stores#edit'
  patch '/stores/:id',   to: 'stores#update'

  # 振込
  get '/transfers',   to: 'transfers#index'
  post '/transfers',   to: 'transfers#create'
  patch '/transfers/:id/reject',   to: 'transfers#reject'
  resources :transfers do
    member do
      patch :confirm
      patch :set_transfer
      patch :update_cash_flow
    end
  end

  # ユーザー
  get    '/users',   to: 'users#index'
  get    '/users/new',   to: 'users#new'
  post   '/users',   to: 'users#create'
  get    '/users/:id/edit',   to: 'users#edit'
  patch  '/users/:id',   to: 'users#update'
  put    '/users/:id',   to: 'users#update'
  resources :users do
    member do
      patch :inactive
      patch :send_login_information
    end
  end
  delete '/users/:id',   to: 'users#destroy'

  # wiki
  get '/wiki/usage/:role', to: 'wiki#index'

  # 未連携word pressセラピスト
  get '/word_press_therapists', to: 'word_press_therapists#index'
  post '/word_press_therapists/link', to: 'word_press_therapists#link'
  resources :word_press_therapists do
    member do
      get :link
    end
  end

  # API
  mount API => '/'
end
