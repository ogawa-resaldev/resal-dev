class ChangeDatatypeOfApplicants < ActiveRecord::Migration[7.0]
  def up
    change_column :applicants, :interview_date, :datetime
    change_column :applicants, :training_date, :datetime
    change_column :applicants, :shooting_date, :datetime
    rename_column :applicants, :interview_date, :interview_datetime
    rename_column :applicants, :training_date, :training_datetime
    rename_column :applicants, :shooting_date, :shooting_datetime
    change_column_comment(:applicants, :interview_datetime, '面接日時')
    change_column_comment(:applicants, :training_datetime, '研修日時')
    change_column_comment(:applicants, :shooting_datetime, '撮影日時')
  end

  def down
    change_column_comment(:applicants, :interview_datetime, '面接日')
    change_column_comment(:applicants, :training_datetime, '研修日')
    change_column_comment(:applicants, :shooting_datetime, '撮影日')
    rename_column :applicants, :interview_datetime, :interview_date
    rename_column :applicants, :training_datetime, :training_date
    rename_column :applicants, :shooting_datetime, :shooting_date
    change_column :applicants, :interview_date, :date
    change_column :applicants, :training_date, :date
    change_column :applicants, :shooting_date, :date
  end
end
