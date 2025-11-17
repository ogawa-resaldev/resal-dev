class AddColumnToBonusPoints < ActiveRecord::Migration[7.0]
  def up
    add_column :bonus_points, :store_group_id, :integer, :after => :user_id, comment: "グループID"
  end

  def down
    remove_column :bonus_points, :store_group_id
  end
end
