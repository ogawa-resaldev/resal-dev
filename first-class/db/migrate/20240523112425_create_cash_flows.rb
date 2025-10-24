class CreateCashFlows < ActiveRecord::Migration[7.0]
  def change
    create_table :cash_flows do |t|
      t.datetime :occurrence_date, :null => false, comment: '発生日'
      t.integer :user_id, :null => false, comment: 'ユーザーID'
      t.integer :reservation_id, comment: '予約ID'
      t.integer :bar_sales_id, comment: 'バー売上ID'
      t.string :miscellaneous_expenses, comment: '雑費'
      t.integer :amount, :null => false, comment: '金額'
      t.integer :direction, :null => false, comment: 'フローの向き。1がセラピスト→店で、2が店→セラピスト。'
      t.integer :transfer_id, comment: '振込ID'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
