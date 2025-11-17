class CreateApplicantStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :applicant_statuses do |t|
      t.string :status_name, :null => false, comment: '応募者ステータス名'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
