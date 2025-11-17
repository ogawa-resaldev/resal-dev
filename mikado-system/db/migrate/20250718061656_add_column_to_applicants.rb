class AddColumnToApplicants < ActiveRecord::Migration[7.0]
  def up
    add_column :applicants, :notification_group_id, :string, :after => :professional_name, comment: "通知グループID"
  end

  def down
    remove_column :applicants, :notification_group_id
  end
end
