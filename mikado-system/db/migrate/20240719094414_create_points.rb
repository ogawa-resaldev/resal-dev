class CreatePoints < ActiveRecord::Migration[7.0]
  def change
    create_table :points do |t|
      t.string :point_name, :null => false, comment: 'ポイント名'
      t.integer :point_type, :null => false, comment: 'ポイントのタイプ。1が予約で、2がボーナス'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
