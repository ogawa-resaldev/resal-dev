class AddColumnToApplicantAutoNotifications < ActiveRecord::Migration[7.0]
  def up
    add_column :applicant_auto_notifications, :execute_flag, :boolean, :default => 1, :after => :store_group_id, comment: "実行フラグ"
  end

  def down
    remove_column :applicant_auto_notifications, :execute_flag
  end
end
