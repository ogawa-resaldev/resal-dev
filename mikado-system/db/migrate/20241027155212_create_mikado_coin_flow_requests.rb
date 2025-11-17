class CreateMikadoCoinFlowRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :mikado_coin_flow_requests do |t|
      t.integer :user_id, :null => false, comment: 'ユーザーID'
      t.string :reason, :null => false, comment: '理由'
      t.integer :direction, :null => false, comment: 'フローの向き。1が入庫で、2が出庫。'
      t.integer :coin, :null => false, comment: 'コイン'
      t.integer :status_id, :null => false, :default => 0, comment: '0で作成される。キャンセルされると1、計上されると2になる。'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
