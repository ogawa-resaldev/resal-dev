class RenameSumAmountColumnToTransfers < ActiveRecord::Migration[7.0]
  def up
    rename_column :transfers, :sum_amount, :transfer_amount
    change_column_null :transfers, :transfer_amount, true
  end

  def down
    rename_column :transfers, :transfer_amount, :sum_amount
    change_column_null :transfers, :sum_amount, false
  end
end
