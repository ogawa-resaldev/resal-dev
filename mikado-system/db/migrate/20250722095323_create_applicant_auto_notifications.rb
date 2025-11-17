class CreateApplicantAutoNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :applicant_auto_notifications do |t|
      t.integer :store_group_id, :null => false, comment: '店舗グループID'
      t.string :target_date, :null => false, comment: '対象日付'
      t.integer :offset_days, :null => false, comment: '基準日から何日前/何日後かを表す'
      t.string :notification_time, :null => false, comment: '通知時間(4桁)'
      t.integer :applicant_mail_template_id, comment: '応募者メールテンプレートID'
      t.integer :applicant_line_template_id, comment: '応募者LINEテンプレートID'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
