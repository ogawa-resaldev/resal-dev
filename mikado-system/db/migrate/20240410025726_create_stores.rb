class CreateStores < ActiveRecord::Migration[7.0]
  def change
    create_table :stores do |t|
      t.string :store_name, :null => false, comment: '店舗名'
      t.string :store_url, :null => false, comment: '店舗URL'
      t.boolean :active_flag, :null => false, :default => false, comment: 'アクティブフラグ'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
