class AddColumnToUserTherapistSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :user_therapist_settings, :new_face, :boolean, :null => false, :default => true, :after => :user_id, comment: "新人フラグ"
    add_column :user_therapist_settings, :rank_id, :integer, :after => :user_id, comment: "ランクID"
  end
end
