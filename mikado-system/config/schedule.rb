# Rails.rootを使用する
require File.expand_path(File.dirname(__FILE__) + "/environment")

# cronを実行する環境変数(RAILS_ENVが指定されていないときはdevelopmentを使用)
rails_env = ENV['RAILS_ENV'] || :development

# cronの実行環境を指定（上記で作成した変数を指定）
set :environment, rails_env

# cronのログファイルの出力先指定
set :output, "#{Rails.root}/log/cron.log"

# 環境変数を渡す
ENV.each { |k, v| env(k, v) }

# mysqlのheart beatを確認
every 15.minutes do
  rake 'mysql:check_heart_beat'
end

# 求人の自動通知
every 1.hours do
  rake 'applicant:notify'
end

# 求人のリコンサイル
every 1.hours do
  rake 'applicant:reconcile'
end

# 事前決済系の確認
every 2.hours do
  rake 'advanced_pay:check_paid_flag'
end

# 毎日0:05にlogやbackupをローテーション
every 1.days, at: '3:05 pm' do
  rake 'rotate:rotate'
end

# 毎日0:10にランキング反映日を確認して、反映日であればadd_rank_frame_image_urlsを更新する
every 1.days, at: '3:10 pm' do
  rake 'rank_frame:rank_frame'
end

# 毎朝8:05にbackupを生成
every 1.days, at: '11:05 pm' do
  rake 'backup:backup'
end

# 毎週月曜3:05にscheduleのwatch設定と更新
every :monday, at: '6:05 pm' do
  rake 'integrate_google_calendar:watch'
end

# 毎週月曜3:15にscheduleのwatch設定と更新
every :monday, at: '6:15 pm' do
  rake 'integrate_google_calendar:bulk_update'
end

# 毎週木曜3:05にscheduleのwatch設定と更新
every :thursday, at: '6:05 pm' do
  rake 'integrate_google_calendar:watch'
end

# 毎週木曜3:15にscheduleのwatch設定と更新
every :thursday, at: '6:15 pm' do
  rake 'integrate_google_calendar:bulk_update'
end
