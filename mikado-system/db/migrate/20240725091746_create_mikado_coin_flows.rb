class CreateMikadoCoinFlows < ActiveRecord::Migration[7.0]
  def change
    create_table :mikado_coin_flows do |t|
      t.integer :user_id, :null => false, comment: 'ユーザーID'
      t.string :reason, :null => false, comment: '理由'
      t.integer :direction, :null => false, comment: 'フローの向き。1が入庫で、2が出庫。'
      t.integer :coin, :null => false, comment: 'コイン'
      t.boolean :recorded_flag, :null => false, :default => false, comment: '入出庫の適用フラグ。'
      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
