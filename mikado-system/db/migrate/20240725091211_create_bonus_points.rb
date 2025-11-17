class CreateBonusPoints < ActiveRecord::Migration[7.0]
  def change
    create_table :bonus_points do |t|
      t.datetime :occurrence_date, :null => false, comment: '発生日'
      t.integer :user_id, :null => false, comment: 'ユーザーID'
      t.string :bonus, comment: 'ボーナス'
      t.decimal :point, precision: 5, scale: 1, :null => false, comment: 'ポイント'
      t.decimal :support_point, precision: 5, scale: 1, :null => false, comment: '応援ポイント'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
