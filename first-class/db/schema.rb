# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_10_29_112259) do
  create_table "applicant_auto_notifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "store_group_id", null: false, comment: "店舗グループID"
    t.boolean "execute_flag", default: true, comment: "実行フラグ"
    t.string "target_date", null: false, comment: "対象日付"
    t.integer "offset_days", null: false, comment: "基準日から何日前/何日後かを表す"
    t.string "notification_time", null: false, comment: "通知時間(4桁)"
    t.integer "applicant_mail_template_id", comment: "応募者メールテンプレートID"
    t.integer "applicant_line_template_id", comment: "応募者LINEテンプレートID"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applicant_details", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "applicant_id", null: false, comment: "応募者ID"
    t.date "application_date", null: false, comment: "応募日"
    t.integer "preferred_store_id", null: false, comment: "希望の所属店舗ID"
    t.string "preferred_store_text", comment: "希望の所属店舗(text)"
    t.string "name", null: false, comment: "お名前"
    t.string "tel", null: false, comment: "電話番号"
    t.string "mail_address", null: false, comment: "メールアドレス"
    t.integer "age", null: false, comment: "年齢"
    t.integer "height", null: false, comment: "身長"
    t.integer "weight", null: false, comment: "体重"
    t.string "nearest_station", null: false, comment: "最寄駅"
    t.string "education", null: false, comment: "学歴"
    t.string "occupation", null: false, comment: "職業"
    t.string "work_frequency", null: false, comment: "出勤頻度"
    t.string "experience_count", null: false, comment: "経験人数"
    t.string "smoking", null: false, comment: "喫煙"
    t.string "has_tattoo", null: false, comment: "タトゥーの有無"
    t.string "therapist_experience", null: false, comment: "セラピスト経験・期間"
    t.string "mosaic", null: false, comment: "モザイク"
    t.string "how_to_know", null: false, comment: "当店をどこで知りましたか？"
    t.text "motivation", comment: "志望動機"
    t.text "self_pr", comment: "自己アピール"
    t.text "other_questions", comment: "その他、ご質問等"
    t.string "image_one_path", comment: "写真1path"
    t.string "image_two_path", comment: "写真2path"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applicant_fees", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "applicant_id", null: false, comment: "応募者ID"
    t.string "fee_name", null: false, comment: "費用名"
    t.integer "amount", null: false, comment: "料金"
    t.string "annotation", comment: "注釈"
    t.date "receive_date", comment: "受取日"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applicant_line_templates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "store_group_id", null: false, comment: "店舗グループID"
    t.string "line_template_name", null: false, comment: "LINEテンプレート名"
    t.text "line_template_body", null: false, comment: "LINEテンプレート内容"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applicant_mail_templates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "store_group_id", null: false, comment: "店舗グループID"
    t.string "mail_template_name", null: false, comment: "メールテンプレート名"
    t.string "mail_template_subject", null: false, comment: "メールテンプレート主題"
    t.text "mail_template_body", null: false, comment: "メールテンプレート内容"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applicant_status_line_templates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "store_group_id", null: false, comment: "店舗グループID"
    t.integer "applicant_status_id", null: false, comment: "応募者ステータスID"
    t.integer "applicant_line_template_id", comment: "応募者LINEテンプレートID"
    t.boolean "default_flag", default: false, comment: "デフォルトフラグ"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applicant_status_mail_templates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "store_group_id", null: false, comment: "店舗グループID"
    t.integer "applicant_status_id", null: false, comment: "応募者ステータスID"
    t.integer "applicant_mail_template_id", comment: "応募者メールテンプレートID"
    t.boolean "default_flag", default: false, comment: "デフォルトフラグ"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applicant_statuses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "status_name", null: false, comment: "応募者ステータス名"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applicants", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "applicant_status_id", null: false, comment: "応募者ステータスID"
    t.boolean "pending_flag", default: false, comment: "保留フラグ"
    t.integer "applicant_store_id", comment: "求人応募店舗ID"
    t.text "note", comment: "状況共有用メモ"
    t.string "pass_classification", comment: "通過区分"
    t.integer "interviewer_id", comment: "面接担当者ID"
    t.datetime "interview_datetime", comment: "面接日時"
    t.string "professional_name", comment: "源氏名"
    t.string "notification_group_id", comment: "通知グループID"
    t.string "instructor", comment: "担当講師"
    t.datetime "training_datetime", comment: "研修日時"
    t.integer "training_adjustment_id", default: 1, comment: "講師調整ID。1で調整中、2で調整済み"
    t.string "photographer_studio", comment: "カメラマン・スタジオ"
    t.datetime "shooting_datetime", comment: "撮影日時"
    t.integer "shooting_adjustment_id", default: 1, comment: "撮影調整ID。1で調整中、2で調整済み"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "back_office_groups", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザーID"
    t.integer "store_group_id", null: false, comment: "グループID"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bonus_points", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "occurrence_date", null: false, comment: "発生日"
    t.integer "user_id", null: false, comment: "ユーザーID"
    t.integer "store_group_id", comment: "グループID"
    t.string "bonus", comment: "ボーナス"
    t.decimal "point", precision: 5, scale: 1, null: false, comment: "ポイント"
    t.decimal "support_point", precision: 5, scale: 1, null: false, comment: "応援ポイント"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cash_flows", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "occurrence_date", null: false, comment: "発生日"
    t.date "cash_flow_period", comment: "締め切り日"
    t.integer "user_id", null: false, comment: "ユーザーID"
    t.integer "store_group_id", comment: "店舗グループID"
    t.integer "reservation_id", comment: "予約ID"
    t.integer "bar_sales_id", comment: "バー売上ID"
    t.string "miscellaneous_expenses", comment: "雑費"
    t.integer "amount", null: false, comment: "金額"
    t.integer "direction", null: false, comment: "フローの向き。1がセラピスト→店で、2が店→セラピスト。"
    t.integer "transfer_id", comment: "振込ID"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "course_details", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "course_id", null: false, comment: "コースID"
    t.string "name", null: false, comment: "表示名"
    t.string "abbreviation", null: false, comment: "略称"
    t.integer "duration", null: false, comment: "所要時間(分)"
    t.integer "price", null: false, comment: "料金(円)"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "courses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "sort_order", default: 100, null: false, comment: "ソート順"
    t.string "name", null: false, comment: "コース名"
    t.string "course_key", null: false, comment: "コースkey"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mikado_coin_flow_requests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザーID"
    t.string "reason", null: false, comment: "理由"
    t.integer "direction", null: false, comment: "フローの向き。1が入庫で、2が出庫。"
    t.integer "coin", null: false, comment: "コイン"
    t.integer "status_id", default: 0, null: false, comment: "0で作成される。キャンセルされると1、計上されると2になる。"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mikado_coin_flows", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザーID"
    t.string "reason", null: false, comment: "理由"
    t.integer "direction", null: false, comment: "フローの向き。1が入庫で、2が出庫。"
    t.integer "coin", null: false, comment: "コイン"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "miscellaneous_expenses_requests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "occurrence_date", null: false, comment: "発生日"
    t.integer "user_id", null: false, comment: "ユーザーID"
    t.integer "store_group_id", null: false, comment: "店舗グループID"
    t.string "miscellaneous_expenses", null: false, comment: "雑費"
    t.integer "amount", null: false, comment: "金額"
    t.integer "direction", null: false, comment: "フローの向き。1がセラピスト→店で、2が店→セラピスト。"
    t.integer "status_id", default: 0, null: false, comment: "0で作成される。キャンセルされると1、計上されると2になる。"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pass_classification_fees", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "pass_classification_id", null: false, comment: "通過区分ID"
    t.string "fee_name", null: false, comment: "費用名"
    t.integer "amount", null: false, comment: "料金"
    t.string "annotation", comment: "注釈"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pass_classifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "store_group_id", null: false, comment: "店舗グループID"
    t.string "classification_name", null: false, comment: "通過区分名"
    t.string "mail_template_subject", null: false, comment: "メールテンプレート主題"
    t.text "mail_template_body", null: false, comment: "メールテンプレート内容"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "point_details", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "point_id", null: false, comment: "ポイントID"
    t.string "point_detail", null: false, comment: "ポイント詳細"
    t.decimal "amount", precision: 5, scale: 1, null: false, comment: "ポイント数"
    t.decimal "support_amount", precision: 5, scale: 1, null: false, comment: "応援ポイント数"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "points", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "point_name", null: false, comment: "ポイント名"
    t.integer "point_type", null: false, comment: "ポイントのタイプ。1が予約で、2がボーナス"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ranks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "rank", null: false, comment: "ランク"
    t.string "name", null: false, comment: "ランク名"
    t.integer "reservation_price", null: false, comment: "指名料"
    t.text "rank_frame_image_url", comment: "ランキング枠の画像url"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservation_cost_details", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "reservation_cost_id", null: false, comment: "予約費用ID"
    t.string "cost_detail", null: false, comment: "費用種別詳細"
    t.integer "amount", null: false, comment: "金額(円)"
    t.integer "back_therapist_amount", null: false, comment: "セラピストバック金額(円)"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservation_costs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "cost_type", null: false, comment: "予約費用種別"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservation_courses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "reservation_id", null: false, comment: "予約ID"
    t.string "course", null: false, comment: "コース"
    t.string "course_detail", null: false, comment: "コース詳細"
    t.integer "duration", null: false, comment: "所要時間(分)"
    t.integer "amount", null: false, comment: "金額(円)"
    t.integer "back_therapist_amount", null: false, comment: "セラピストバック金額(円)"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservation_fees", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "reservation_id", null: false, comment: "予約ID"
    t.string "fee_type", null: false, comment: "費用種別"
    t.string "fee_detail", null: false, comment: "費用詳細"
    t.integer "amount", null: false, comment: "金額(円)"
    t.integer "back_therapist_amount", null: false, comment: "セラピストバック金額(円)"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservation_payment_methods", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "payment_method", null: false, comment: "決済方法"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservation_points", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "reservation_id", null: false, comment: "予約ID"
    t.string "point_name", null: false, comment: "ポイント名"
    t.string "point_detail", null: false, comment: "ポイント詳細"
    t.decimal "point", precision: 5, scale: 1, null: false, comment: "ポイント"
    t.decimal "support_point", precision: 5, scale: 1, null: false, comment: "応援ポイント"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservation_statuses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "status_name", null: false, comment: "予約ステータス名"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservation_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "type_name", null: false, comment: "予約タイプ"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "store_id", null: false, comment: "店舗ID"
    t.integer "therapist_id", comment: "セラピストID"
    t.string "preferred_therapist", comment: "希望セラピスト"
    t.datetime "reservation_datetime", null: false, comment: "予約日時"
    t.string "name", null: false, comment: "予約名"
    t.string "contact_method", comment: "連絡手段"
    t.integer "meeting_count", default: 0, null: false, comment: "対面回数"
    t.integer "call_count", default: 0, null: false, comment: "通話件数"
    t.string "tel", null: false, comment: "予約電話番号"
    t.string "mail_address", null: false, comment: "予約メールアドレス"
    t.string "place", null: false, comment: "利用場所"
    t.string "address", comment: "住所"
    t.string "sms", comment: "SMS"
    t.text "option", comment: "オプション"
    t.text "ng", comment: "NG"
    t.string "discount", comment: "割引"
    t.text "note", comment: "その他"
    t.text "whiteboard", comment: "情報共有用のホワイトボード"
    t.integer "reservation_type_id", null: false, comment: "予約タイプID"
    t.boolean "adjustment_flag", default: false, null: false, comment: "セラピストとの調整フラグ"
    t.integer "reservation_payment_method_id", null: false, comment: "支払い方法ID"
    t.boolean "paid_flag", default: false, null: false, comment: "支払いフラグ"
    t.integer "reservation_status_id", null: false, comment: "予約ステータスID"
    t.datetime "confirmation_date", comment: "予約確定日"
    t.datetime "confirmation_user_id", comment: "予約確定者"
    t.datetime "fulfillment_date", comment: "予約遂行日"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reviews", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザーID"
    t.string "reservation_name", null: false, comment: "予約名"
    t.string "reservation_mail_address", null: false, comment: "予約メールアドレス"
    t.string "nickname", null: false, comment: "ニックネーム"
    t.string "age", null: false, comment: "年齢"
    t.date "post_date", null: false, comment: "投稿日"
    t.text "content", null: false, comment: "内容"
    t.boolean "display_flag", default: false, null: false, comment: "表示フラグ"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "store_groups", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false, comment: "グループ名"
    t.integer "credit_fee_percentage", default: 0, null: false, comment: "クレジット手数料のパーセンテージ"
    t.text "mail_api", comment: "メールAPI"
    t.string "mail_name", comment: "メールの表記名"
    t.text "mail_signature", comment: "メールの署名"
    t.text "mail_transfer_bank", comment: "メールの銀行振込先"
    t.text "mail_credit_1", comment: "メールのクレジット情報1"
    t.text "mail_credit_2", comment: "メールのクレジット情報2"
    t.string "line_client_id", comment: "LINEのクライアントID"
    t.string "line_client_secret", comment: "LINEのクライアントSECRET"
    t.string "line_default_target_id", comment: "LINEのデフォルトの送信ID"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stores", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "store_name", null: false, comment: "店舗名"
    t.string "store_url", null: false, comment: "店舗URL"
    t.integer "store_group_id", comment: "店舗グループID"
    t.boolean "active_flag", default: false, null: false, comment: "アクティブフラグ"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transfers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザーID"
    t.integer "store_group_id", comment: "店舗グループID"
    t.integer "transfer_amount", comment: "合計金額"
    t.integer "direction", null: false, comment: "フローの向き。1がセラピスト→店で、2が店→セラピスト。"
    t.datetime "transfer_date", comment: "振込日"
    t.datetime "transfer_deadline", comment: "振込期限"
    t.boolean "confirmation_flag", default: false, null: false, comment: "振込確認フラグ"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_rank_reflection_dates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "reflection_date", null: false, comment: "反映日"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_ranks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザーID"
    t.integer "rank_id", null: false, comment: "ランクID"
    t.date "reflection_date", comment: "反映日"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "role", null: false, comment: "権限"
    t.string "name", null: false, comment: "権限名"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_therapist_settings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザーID"
    t.integer "rank_id", comment: "ランクID"
    t.boolean "new_face", default: true, null: false, comment: "新人フラグ"
    t.integer "therapist_back_ratio", null: false, comment: "セラピストバック率"
    t.integer "mikado_coin_balance", default: 0, null: false, comment: "帝コイン残高"
    t.text "auto_complete", comment: "自動補完"
    t.string "mail_address", comment: "メールアドレス"
    t.text "account_information", comment: "口座情報"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_therapists", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "ユーザーID"
    t.integer "store_id", null: false, comment: "店舗ID"
    t.integer "therapist_id", comment: "セラピストID"
    t.string "notification_group_id", default: "", null: false, comment: "通知グループID"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_role_id", null: false, comment: "ユーザー権限ID"
    t.string "name", null: false, comment: "ユーザー名"
    t.string "login_id", null: false, comment: "ログインID"
    t.string "password_digest", null: false, comment: "パスワード"
    t.boolean "active_flag", default: true, null: false, comment: "アクティブフラグ"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
