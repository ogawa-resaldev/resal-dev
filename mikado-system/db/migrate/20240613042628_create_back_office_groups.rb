class CreateBackOfficeGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :back_office_groups do |t|
      t.integer :user_id, :null => false, comment: 'ユーザーID'
      t.integer :store_group_id, :null => false, comment: 'グループID'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
