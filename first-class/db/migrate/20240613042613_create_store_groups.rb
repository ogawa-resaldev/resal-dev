class CreateStoreGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :store_groups do |t|
      t.string :name, :null => false, comment: 'グループ名'
      t.string :dot_env_key, :null => false, comment: 'グループごとにDOTENVで使用するキー。大文字で登録する想定。'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
