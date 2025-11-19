class MoveColumnNotificationGroupIdToUserTherapists < ActiveRecord::Migration[7.0]
  def up
    add_column :user_therapists, :notification_group_id, :string, :null => false, :default => "", :after => :therapist_id, comment: "通知グループID"
    remove_column :user_therapist_settings, :notification_group_id
  end

  def down
    add_column :user_therapist_settings, :notification_group_id, :string, :null => false, :default => "", :after => :therapist_back_ratio, comment: "通知グループID"
    remove_column :user_therapists, :notification_group_id
  end
end
