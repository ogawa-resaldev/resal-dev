class CreateApplicants < ActiveRecord::Migration[7.0]
  def change
    create_table :applicants do |t|
      t.integer :applicant_status_id, :null => false, comment: '応募者ステータスID'
      t.integer :applicant_store_id, comment: '求人応募店舗ID。システムで登録した場合はnullにする。'
      t.string :pass_classification, comment: '通過区分'
      t.integer :interviewer_id, comment: '面接担当者ID'
      t.date :interview_date, comment: '面接日'
      t.string :professional_name, comment: '源氏名'
      t.string :instructor, comment: '担当講師'
      t.date :training_date, comment: '研修日'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
