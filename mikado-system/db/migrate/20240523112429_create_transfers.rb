class CreateTransfers < ActiveRecord::Migration[7.0]
  def change
    create_table :transfers do |t|
      t.integer :user_id, :null => false, comment: 'ユーザーID'
      t.integer :sum_amount, :null => false, comment: '合計金額'
      t.integer :direction, :null => false, comment: 'フローの向き。1がセラピスト→店で、2が店→セラピスト。'
      t.datetime :transfer_date, comment: '振込日'
      t.datetime :transfer_deadline, comment: '振込期限'
      t.boolean :confirmation_flag, :null => false, :default => false, comment: '振込確認フラグ'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
