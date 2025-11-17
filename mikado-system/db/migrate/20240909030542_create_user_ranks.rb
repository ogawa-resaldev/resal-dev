class CreateUserRanks < ActiveRecord::Migration[7.0]
  def change
    create_table :user_ranks do |t|
      t.integer :user_id, :null => false, comment: 'ユーザーID'
      t.integer :rank_id, :null => false, comment: 'ランクID'
      t.date :reflection_date, default: nil, comment: '反映日'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
