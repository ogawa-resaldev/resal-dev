class AddColumnToStores < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :store_group_id, :integer, :after => :store_url, comment: "店舗グループID"
  end
end
