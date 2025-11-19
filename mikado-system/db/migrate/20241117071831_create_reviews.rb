class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.integer :user_id, :null => false, comment: 'ユーザーID'
      t.string :reservation_name, :null => false, comment: '予約名'
      t.string :reservation_mail_address, :null => false, comment: '予約メールアドレス'
      t.string :nickname, :null => false, comment: 'ニックネーム'
      t.string :age, :null => false, comment: '年齢'
      t.date :post_date, :null => false, comment: '投稿日'
      t.text :content, limit: 10000, :null => false, comment: '内容'
      t.boolean :display_flag, :null => false, :default => false, comment: '表示フラグ'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
