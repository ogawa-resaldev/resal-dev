# マスター系テーブルのseed。全環境共通で使用する想定。
require "csv"

# ========== 全マスターテーブルを TRUNCATE ==========
master_tables = %w[
  reservation_costs
  reservation_cost_details
  courses
  course_details
  ranks
  user_roles
  store_groups
  stores
  reservation_statuses
  reservation_types
  reservation_payment_methods
]

ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS = 0;")
master_tables.each do |table|
  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table};")
end
ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS = 1;")

# ========== ここから INSERT ==========

# 予約コスト
CSV.foreach('db/seeds/csv_master/reservation_cost.csv', headers: true) do |row|
  ReservationCost.create!(
    id: row['id'],
    cost_type: row['cost_type']
  )
end

# 予約コスト詳細
CSV.foreach('db/seeds/csv_master/reservation_cost_detail.csv', headers: true) do |row|
  ReservationCostDetail.create!(
    id: row['id'],
    reservation_cost_id: row['reservation_cost_id'],
    cost_detail: row['cost_detail'],
    amount: row['amount'],
    back_therapist_amount: row['back_therapist_amount']
  )
end

# コース
CSV.foreach('db/seeds/csv_master/course.csv', headers: true) do |row|
  Course.create!(
    id: row['id'],
    name: row['name'],
    course_key: row['course_key']
  )
end

# コース詳細
CSV.foreach('db/seeds/csv_master/course_detail.csv', headers: true) do |row|
  CourseDetail.create!(
    id: row['id'],
    course_id: row['course_id'],
    name: row['name'],
    abbreviation: row['abbreviation'],
    duration: row['duration'],
    price: row['price']
  )
end

# ランク
CSV.foreach('db/seeds/csv_master/rank.csv', headers: true) do |row|
  Rank.create!(
    id: row['id'],
    rank: row['rank'],
    name: row['name'],
    reservation_price: row['reservation_price']
  )
end

# ユーザー権限
CSV.foreach('db/seeds/csv_master/user_role.csv', headers: true) do |row|
  UserRole.create!(
    id: row['id'],
    role: row['role'],
    name: row['name']
  )
end

# 店舗グループ
CSV.foreach('db/seeds/csv_master/store_group.csv', headers: true) do |row|
  StoreGroup.create!(
    id: row['id'],
    name: row['name'],
    credit_fee_percentage: row['credit_fee_percentage'],
    mail_api: row['mail_api'],
    mail_name: row['mail_name'],
    mail_signature: row['mail_signature'],
    mail_transfer_bank: row['mail_transfer_bank'],
    mail_credit_1: row['mail_credit_1'],
    mail_credit_2: row['mail_credit_2'],
    line_client_id: row['line_client_id'],
    line_client_secret: row['line_client_secret'],
    line_default_target_id: row['line_default_target_id']
  )
end

# 店舗
CSV.foreach('db/seeds/csv_master/store.csv', headers: true) do |row|
  Store.create!(
    id: row['id'],
    store_name: row['store_name'],
    store_url: row['store_url'],
    store_group_id: row['store_group_id'],
    active_flag: row['active_flag']
  )
end

# 予約ステータス
CSV.foreach('db/seeds/csv_master/reservation_status.csv', headers: true) do |row|
  ReservationStatus.create!(
    id: row['id'],
    status_name: row['status_name']
  )
end

# 予約タイプ
CSV.foreach('db/seeds/csv_master/reservation_type.csv', headers: true) do |row|
  ReservationType.create!(
    id: row['id'],
    type_name: row['type_name']
  )
end

# 予約決済方法
CSV.foreach('db/seeds/csv_master/reservation_payment_method.csv', headers: true) do |row|
  ReservationPaymentMethod.create!(
    id: row['id'],
    payment_method: row['payment_method']
  )
end
