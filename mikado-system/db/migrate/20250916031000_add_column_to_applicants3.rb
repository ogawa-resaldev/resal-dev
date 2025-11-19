class AddColumnToApplicants3 < ActiveRecord::Migration[7.0]
  def up
    add_column :applicants, :pending_flag, :boolean, :default => 0, :after => :applicant_status_id, comment: "保留フラグ"
  end

  def down
    remove_column :applicants, :pending_flag
  end
end
