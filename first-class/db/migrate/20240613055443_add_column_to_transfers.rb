class AddColumnToTransfers < ActiveRecord::Migration[7.0]
  def change
    add_column :transfers, :store_group_id, :integer, :after => :user_id, comment: "店舗グループID"
  end
end
