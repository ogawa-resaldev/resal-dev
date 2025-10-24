class CreateReservations < ActiveRecord::Migration[7.0]
  def change
    create_table :reservations do |t|
      t.integer :store_id, :null => false, comment: '店舗ID'
      t.integer :therapist_id, comment: 'セラピストID'
      t.string :preferred_therapist, comment: '希望セラピスト'
      t.datetime :reservation_datetime, :null => false, comment: '予約日時'
      t.string :name, :null => false, comment: '予約名'
      t.string :tel, :null => false, comment: '予約電話番号'
      t.string :mail_address, :null => false, comment: '予約メールアドレス'
      t.string :place, :null => false, comment: '利用場所'
      t.string :address, comment: '住所'
      t.string :sms, comment: 'SMS'
      t.string :option, comment: 'オプション'
      t.string :ng, comment: 'NG'
      t.string :note, comment: 'その他'
      t.integer :reservation_type_id, :null => false, comment: '予約タイプID'
      t.boolean :adjustment_flag, :null => false, :default => false, comment: 'セラピストとの調整フラグ'
      t.integer :reservation_payment_method_id, :null => false, comment: '支払い方法ID'
      t.boolean :paid_flag, :null => false, :default => false, comment: '支払いフラグ'
      t.integer :reservation_status_id, :null => false, comment: '予約ステータスID'
      t.datetime :confirmation_date, comment: '予約確定日'
      t.datetime :confirmation_user_id, comment: '予約確定者'
      t.datetime :fulfillment_date, comment: '予約遂行日'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
