class CreateMiscellaneousExpensesRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :miscellaneous_expenses_requests do |t|
      t.datetime :occurrence_date, :null => false, comment: '発生日'
      t.integer :user_id, :null => false, comment: 'ユーザーID'
      t.integer :store_group_id, :null => false, comment: '店舗グループID'
      t.string :miscellaneous_expenses, :null => false, comment: '雑費'
      t.integer :amount, :null => false, comment: '金額'
      t.integer :direction, :null => false, comment: 'フローの向き。1がセラピスト→店で、2が店→セラピスト。'
      t.integer :status_id, :null => false, :default => 0, comment: '0で作成される。キャンセルされると1、計上されると2になる。'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
