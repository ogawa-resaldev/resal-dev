class RemoveRecordedFlagFromMikadoCoinFlows < ActiveRecord::Migration[7.0]
  def up
    remove_column :mikado_coin_flows, :recorded_flag
  end

  def down
    add_column :mikado_coin_flows, :recorded_flag, :boolean, default: false, null: false, after: :coin, commemt: '入出庫の適用フラグ。'
  end
end
