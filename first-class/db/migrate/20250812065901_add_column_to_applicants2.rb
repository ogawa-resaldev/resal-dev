class AddColumnToApplicants2 < ActiveRecord::Migration[7.0]
  def up
    add_column :applicants, :note, :text, :limit => 10000, :after => :applicant_store_id, comment: "状況共有用メモ"
    add_column :applicants, :training_adjustment_id, :integer, :default => 1, :after => :training_date, comment: "講師調整ID。1で調整中、2で調整済み"
    add_column :applicants, :photographer_studio, :string, :after => :training_adjustment_id, comment: "カメラマン・スタジオ"
    add_column :applicants, :shooting_date, :date, :default => nil, :after => :photographer_studio, comment: "撮影日"
    add_column :applicants, :shooting_adjustment_id, :integer, :default => 1, :after => :shooting_date, comment: "撮影調整ID。1で調整中、2で調整済み"
  end

  def down
    remove_column :applicants, :note
    remove_column :applicants, :training_adjustment_id
    remove_column :applicants, :photographer_studio
    remove_column :applicants, :shooting_date
    remove_column :applicants, :shooting_adjustment_id
  end
end
