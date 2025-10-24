# テスト用データのseed。

# ユーザー
User.create(
  id: 1,
  user_role_id: 2,
  name: 'resal',
  login_id: 'resal',
  password_digest: 'password'
)
User.create(
  id: 2,
  user_role_id: 2,
  name: 'テスト内勤',
  login_id: 'test_bo',
  password_digest: 'password'
)

# ユーザー_セラピスト設定
UserTherapistSetting.create(
  id: 1,
  user_id: 1,
  therapist_back_ratio: 50,
  notification_group_id: "U5587c15d74a7557a9022886ada0c68b2"
)

# ユーザー_セラピスト
UserTherapist.create(
  id: 1,
  user_id: 1,
  store_id: 1,
  therapist_id: 21
)
UserTherapist.create(
  id: 2,
  user_id: 1,
  store_id: 7,
  therapist_id: 21
)

# 店舗
Store.create(
  id: 7,
  store_name: '保留店',
  store_url: 'https://mikado-tokyo.com/nago/',
  active_flag: 1
)

# 予約
## 予約1(遂行済み)
Reservation.create(
  id: 1,
  store_id: 7,
  therapist_id: 21,
  preferred_therapist: "焔さん",
  reservation_datetime: Time.current.prev_month.change(min: 00),
  name: '一ヶ月前ちゃん',
  tel: '0123456789',
  mail_address: 'dummy1@test.mikado.com',
  place: '新宿駅',
  address: nil,
  sms: 'どちらでも良い',
  option: nil,
  ng: nil,
  note: nil,
  reservation_type_id: 2,
  adjustment_flag: 1,
  reservation_payment_method_id: 1,
  paid_flag: 1,
  reservation_status_id: 4,
  confirmation_date: Time.current.prev_month.ago(3.days),
  confirmation_user_id: 1,
  fulfillment_date: Time.current.prev_month,
  created_at: Time.current.prev_month.ago(3.days),
  updated_at: Time.current.prev_month
)
ReservationCourse.create(
  id: 1,
  reservation_id: 1,
  course: '性感マッサージコース',
  course_detail: '120分',
  duration: '120',
  amount: 19000,
  back_therapist_amount: 9500
)
ReservationFee.create(
  id: 1,
  reservation_id: 1,
  fee_type: '指名料',
  fee_detail: 'ランクなし',
  amount: 1000,
  back_therapist_amount: 1000
)
ReservationFee.create(
  id: 2,
  reservation_id: 1,
  fee_type: '交通費',
  fee_detail: '区分1',
  amount: 500,
  back_therapist_amount: 500
)
ReservationFee.create(
  id: 3,
  reservation_id: 1,
  fee_type: '割引',
  fee_detail: '新人割',
  amount: -5000,
  back_therapist_amount: -2500
)
## 予約2(キャンセル済み)
Reservation.create(
  id: 2,
  store_id: 7,
  therapist_id: 21,
  preferred_therapist: "サンプルさん",
  reservation_datetime: Time.current.ago(3.weeks).change(min: 00),
  name: '3週間前ちゃん',
  tel: '0223456789',
  mail_address: 'dummy2@test.mikado.com',
  place: '渋谷',
  address: 'スクランブル交差点',
  sms: '希望する',
  option: nil,
  ng: 'キス、クンニ',
  note: '初めてなので、痛くしないで欲しい。',
  reservation_type_id: 2,
  adjustment_flag: 0,
  reservation_payment_method_id: 1,
  paid_flag: 0,
  reservation_status_id: 3,
  confirmation_date: Time.current.ago(3.weeks).ago(3.days),
  confirmation_user_id: 1,
  fulfillment_date: Time.current.prev_month,
  created_at: Time.current.ago(3.weeks).ago(3.days),
  updated_at: Time.current.ago(3.weeks)
)
ReservationCourse.create(
  id: 2,
  reservation_id: 2,
  course: '性感マッサージコース',
  course_detail: '120分',
  duration: '120',
  amount: 19000,
  back_therapist_amount: 9500
)
ReservationFee.create(
  id: 4,
  reservation_id: 2,
  fee_type: '指名料',
  fee_detail: 'ランクなし',
  amount: 1000,
  back_therapist_amount: 1000
)
ReservationFee.create(
  id: 5,
  reservation_id: 2,
  fee_type: '交通費',
  fee_detail: '区分2',
  amount: 1000,
  back_therapist_amount: 1000
)
ReservationFee.create(
  id: 6,
  reservation_id: 2,
  fee_type: '割引',
  fee_detail: '新人割',
  amount: -5000,
  back_therapist_amount: -2500
)
