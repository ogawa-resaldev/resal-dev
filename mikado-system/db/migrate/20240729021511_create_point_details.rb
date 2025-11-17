class CreatePointDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :point_details do |t|
      t.integer :point_id, :null => false, comment: 'ポイントID'
      t.string :point_detail, :null => false, comment: 'ポイント詳細'
      t.decimal :amount, precision: 5, scale: 1, :null => false, comment: 'ポイント数'
      t.decimal :support_amount, precision: 5, scale: 1, :null => false, comment: '応援ポイント数'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
