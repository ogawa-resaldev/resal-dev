class CreateUserRankReflectionDates < ActiveRecord::Migration[7.0]
  def change
    create_table :user_rank_reflection_dates do |t|
      t.date :reflection_date, :null => false, comment: '反映日'

      t.timestamps
    end
  end
end
